resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name   #project name and envir name 
    }
  )
  }


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.internet_gateway_tags,
    {
        Name = local.resource_name
    }

  )
}

#public subnet #
resource "aws_subnet" "public" {
  count =  length(var.public_subnet_cidrs)
  availability_zone =  local.azs_names[count.index] # terraform subnet
  map_public_ip_on_launch  = true    # public subnet ki public zone evvali
  vpc_id     = aws_vpc.main.id #vpc id is same go and look resoucre vpc 
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-public-${local.azs_names[count.index]}"
    }

  )
}

#private subnet 
resource "aws_subnet" "private" {
  count =  length(var.private_subnet_cidrs)
  availability_zone =  local.azs_names[count.index] # terraform subnet
  vpc_id     = aws_vpc.main.id #vpc id is same go and look resoucre vpc 
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-private-${local.azs_names[count.index]}"
    }

  )
}

#database subnet 
resource "aws_subnet" "database" {
  count =  length(var.database_subnet_cidrs)
  availability_zone =  local.azs_names[count.index] # terraform subnet
  vpc_id     = aws_vpc.main.id #vpc id is same go and look resoucre vpc 
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-database-${local.azs_names[count.index]}"
    }

   )
}

#  Elastic ip ##
resource "aws_eip" "nat" {    #terraform eip aws 
  domain   = "vpc"
}

# NAT GATEWAY 

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # public subnet lo add chesthunamu and [0] means only one nat gateway tiskontunamu

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = "${local.resource_name}"   #here i need only resource_name
    }

   )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]  #  internet gateway lo gw ani vachavu (1st igw nee create cheyali nat ki igw depend avuthundi)
}

# public route table #
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id                     #  terraform aws_route_table

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public"     #expense-dev is coming   #here i need only resource_name
    }
  )
}

# private route table #
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.priavte_route_table_tags,
    {
        Name = "${local.resource_name}-private"    #expense-dev is coming   #here i need only resource_name
    }
  )
}

# database route table #
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.resource_name}-database"     #expense-dev is coming   #here i need only resource_name
    }
  )
}

# public aws_route ###
resource "aws_route" "public_route" {                                   #terraform aws route #(route edit chesi destination lo igw evvali only public)
  route_table_id            = aws_route_table.public.id       # go to search route table name what if you entered in route table then enter aws route
  destination_cidr_block    = "0.0.0.0/0"          # igw
  gateway_id  = aws_internet_gateway.gw.id
}

# private aws_route ###
resource "aws_route" "private_route" {                                   
  route_table_id            = aws_route_table.private.id       
  destination_cidr_block    = "0.0.0.0/0"          # igw
  nat_gateway_id = aws_nat_gateway.NAT.id
}

# private aws_route ###
resource "aws_route" "database_route" {                                  
  route_table_id            = aws_route_table.database.id       
  destination_cidr_block    = "0.0.0.0/0"          # igw
  nat_gateway_id = aws_nat_gateway.NAT.id
}

# public route table associatoin ##
resource "aws_route_table_association" "public" {        #terraform route table assoication
  count = length(var.public_subnet_cidrs)         
  subnet_id      = element(aws_subnet.public[*].id,count.index)     #terrform elements 
  route_table_id = aws_route_table.public.id
}

# private route table associatoin ##
resource "aws_route_table_association" "private" {       
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

# database route table associatoin ##
resource "aws_route_table_association" "database" {        
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
}
