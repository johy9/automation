Concept Check
You now have the three pillars of a Terraform configuration:

- main.tf: The Logic (What to build).
- variables.tf: The Interface (What inputs are allowed).
- terraform.tfvars: The Data (What specific values to use).

##Concept Check: The Data Flow
### Undersstanding the flow is the key to mastering terrafrom

terraform.tfvars (Data)

Holds: vpc_cidr = "10.0.0.0/16"

Passes to ->

Root variables.tf (Declaration)

Passes to ->

Root main.tf (The Module Call)

vpc_cidr = var.vpc_cidr

Passes to ->

modules/vpc/variables.tf (Module Declaration)

Passes to ->

modules/vpc/main.tf (The Resource)

cidr_block = var.vpc_cidr


2. Run the Move Command The syntax is terraform state mv <OLD_ADDRESS> <NEW_ADDRESS>.


Bash
terraform state mv aws_vpc.main module.vpc.aws_vpc.main
terraform state mv module.vpc.aws_vpc.main module.vpc.aws_vpc.this