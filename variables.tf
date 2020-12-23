variable "instance_name" {
  default = "Server"
  description = "Instance name"
}

variable "ami_id" {
  default = "ami-00ddb0e5626798373"
  description = "ami by region"
}

variable "number_of_instances" {
  description = "number of instances to make"
  default = 2
}

variable "tags" {
  default = {
    created_by = "terraform"
 }
}
