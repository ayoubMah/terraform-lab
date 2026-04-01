# Task 5 Prediction

  I expect Terraform to be slower than kubectl for creating a single resource because:
  - Terraform must read the full state file before doing anything
  - It runs a plan phase (API diff) before the apply
  - It initializes the provider on first run

  kubectl sends one API call directly. Terraform sends many.

  The tradeoff: kubectl is faster for one resource, once.
  Terraform is faster for 100 resources, repeatedly, safely.
