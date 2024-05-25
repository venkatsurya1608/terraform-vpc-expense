# vpc variables
variable "project_name" {
    type = string
  
}

variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
    type = map
}    



variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
  
}


variable "vpc_tags" {
    type = map
    default = {}
  
}
# igw subnet variables
variable "internet_gateway_tags" {
    type = map
    default = {}
  
}

# public subnet variables
variable "public_subnet_cidrs" {     #manditory
    type = list
    validation {
        condition = length(var.public_subnet_cidrs) == 2   #terraform validation condition
        error_message = "please give me 2 public valid subnets CIDR"
    }
}    

variable "public_subnet_cidrs_tags" {  #optional
    type = map
    default = {}
}

# priavte subnet variables
variable "private_subnet_cidrs" {  # manditory
    type = list
    validation {
      condition = length(var.private_subnet_cidrs) == 2
      error_message = "please provide valid priavte subnet CIDR"
    }
  
}

variable "private_subnet_cidrs_tags" {
    type = map
    default = {}
  
}

# # database subnet variables
variable "database_subnet_cidrs" {
    type = list
    validation {
      condition = length(var.database_subnet_cidrs) == 2
    error_message = "please provide valid database subnet CIDR"
    }
    
}

variable "database_subnet_cidrs_tags" {
    type = map
    default = {}
  
} 


variable "nat_gateway_tags" {
    type = map
    default = {}
}

# route tables variables

variable "public_route_table_tags" {
    default = {}
  
}

variable "priavte_route_table_tags" {
    default = {}
}

variable "database_route_table_tags" {
    default = {}
  
}

# peering connection ##
variable "is_peering_required" {
    type = bool
    default = false
  
}

variable "acceptor_vpc_id" {
    type = string
    default = ""     # ""  this means default value 
  
}

variable "vpc_peering_tags" {
    default = {}
  
}

