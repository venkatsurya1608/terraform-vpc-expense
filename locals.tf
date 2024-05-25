locals {
  resource_name  = "${var.project_name}-${var.environment}"   #project name and envir name 
  azs_names = slice(data.aws_availability_zones.available.names, 0,2)   #terraform slice function 
}
