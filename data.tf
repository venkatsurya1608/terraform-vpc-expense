data "aws_availability_zones" "available" {    ## terraform Data Source: aws_availability_zones
    state = "available"
}

# data "aws_arm" "available" {
#     state = "available"
  
#}

data "aws_vpc" "default" {
    default = true
  
}

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}