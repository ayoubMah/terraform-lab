 Week 06 Demo — Medicare+ Platform Layer

  Structure (10 min tight)

  ┌─────────┬──────────────────────────────┬────────┐
  │  Block  │           Content            │  Time  │
  ├─────────┼──────────────────────────────┼────────┤
  │ Opening │ The problem, the stakes      │ 1 min  │
  ├─────────┼──────────────────────────────┼────────┤
  │ Task 1  │ Module pattern + state proof │ 2 min  │
  ├─────────┼──────────────────────────────┼────────┤
  │ Task 2  │ Before/after with real app   │ 4 min  │
  ├─────────┼──────────────────────────────┼────────┤
  │ Task 3  │ Change + rollback            │ 2 min  │
  ├─────────┼──────────────────────────────┼────────┤
  │ Close   │ What we gained               │ 30 sec │
  └─────────┴──────────────────────────────┴────────┘

  ---
  Opening (1 min) — say this, no commands

  ▎ "Medicare+ is a healthcare platform. Patient data — prescriptions, diagnoses, billing — lives in a MySQL database in medicare-prod. Three teams share the same Kubernetes cluster: dev, staging, prod.

  ▎ The question I'm answering this week: who sets up the cluster foundation, and how do we guarantee that every environment is isolated, resource-capped, and HIPAA-compliant — before a single line of application
   code is deployed?

  ▎ The answer is Terraform. Let me show you what that means in practice."

  ---
  Task 1 — Platform layer (2 min)

  # One module, three environments, zero manual kubectl
  cat main.tf

  ▎ "One blueprint. Three calls. Dev gets 2 CPU and 4Gi. Prod gets 8 CPU and 16Gi. Same security controls everywhere."

  # Show all 27 resources Terraform manages
  terraform state list

  # Show the namespaces — all labeled managed-by=terraform
  kubectl get namespaces | grep medicare
  kubectl get namespace medicare-prod -o jsonpath='{.metadata.labels}' && echo

  📸 Screenshot: state list + namespaces

  # Drift demo — simulate rogue kubectl
  kubectl delete resourcequota medicare-dev-quota -n medicare-dev
  terraform plan | grep -A5 "will be created"
  terraform apply -target=module.dev --auto-approve
  kubectl get resourcequota -n medicare-dev

  ▎ "Someone deleted the quota manually. Terraform detected it in seconds and restored it. That's the contract."

  📸 Screenshot: plan showing drift → restored

  ---
  Task 2 — Network isolation with the real app (4 min)

  Setup

  # Launch attacker pod in medicare-dev
  kubectl run attacker --image=alpine --restart=Never -n medicare-dev -- sleep 3600
  kubectl wait --for=condition=Ready pod/attacker -n medicare-dev

  BEFORE — remove policies temporarily to show the default

  # Temporarily remove network policies from prod
  kubectl delete networkpolicy medicare-prod-deny-all-ingress -n medicare-prod
  kubectl delete networkpolicy medicare-prod-allow-intra-ns -n medicare-prod

  # Verify they're gone
  kubectl get networkpolicy -n medicare-prod

  ▎ "This is the default state of Kubernetes — no policies. Watch what a dev pod can do."

  # From medicare-dev, hit the real Medicare+ portal in medicare-prod
  kubectl exec attacker -n medicare-dev -- wget -T 5 -O- \
    http://medicare-portal-service.medicare-prod.svc.cluster.local

  📸 Screenshot: app response returned — patient data portal reachable from dev

  ▎ "A dev pod just reached the production Medicare+ portal. In a real system, this is the MySQL database holding patient records. Unrestricted, no audit trail, no protection. This is the threat."

  AFTER — reapply Terraform

  terraform apply -target=module.production --auto-approve
  kubectl get networkpolicy -n medicare-prod

  ▎ "Terraform restores the baseline in one command. Now watch."

  # Same attacker, same target
  kubectl exec attacker -n medicare-dev -- wget -T 5 -O- \
    http://medicare-portal-service.medicare-prod.svc.cluster.local

  📸 Screenshot: wget: download timed out

  ▎ "Blocked. Dev cannot reach prod. Not a firewall rule on a router somewhere — a Kubernetes NetworkPolicy, defined in Terraform, version-controlled in Git, reproducible in 30 seconds."

  RBAC proof — 30 seconds

  kubectl auth can-i delete pods \
    --as=system:serviceaccount:medicare-prod:medicare-app -n medicare-prod
  # no

  kubectl auth can-i get pods \
    --as=system:serviceaccount:medicare-prod:medicare-app -n medicare-prod
  # yes

  📸 Screenshot: no / yes

  ▎ "The app identity can read pods. It cannot delete, create, or touch other namespaces. Least privilege — HIPAA §164.312a."

  # Cleanup attacker pod
  kubectl delete pod attacker -n medicare-dev

  ---
  Task 3 — Change management (2 min)

  # Show git history — infrastructure as code
  git log --oneline

  ▎ "Every infrastructure change has a commit, an author, a timestamp. This is the audit trail."

  # Make a real change — increase dev pod limit
  # (edit main.tf: pod_limit = "15")
  terraform plan

  📸 Screenshot: plan showing exactly "10" -> "15" — nothing else

  ▎ "Before anything touches the cluster, we see the exact diff. One line changed. This goes through PR review before apply."

  terraform apply --auto-approve
  kubectl describe resourcequota medicare-dev-quota -n medicare-dev | grep pods

  # Rollback
  git revert HEAD --no-edit
  terraform plan
  terraform apply --auto-approve
  kubectl describe resourcequota medicare-dev-quota -n medicare-dev | grep pods

  📸 Screenshot: quota at 15 → back to 10

  ▎ "Rollback is two commands. Git revert, terraform apply. No kubectl magic, no 'what was the value before?' — it's in the history."

  ---
  Close (30 sec)

  ▎ "Before this week: namespaces created manually, no quotas, no network isolation, no audit trail. One misconfigured pod could consume all cluster resources or reach patient data in prod.

  ▎ After: 27 resources, three environments, enforced by code, version-controlled, reviewable, and restorable in under 30 seconds.

  ▎ That's the platform layer. That's what ArgoCD dep[Iloys on top of."
