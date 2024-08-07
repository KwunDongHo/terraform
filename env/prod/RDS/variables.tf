variable "db_name" {
  description = "RDS DB Name"
  type        = string
  default     = "sportlink"
}

variable "db_username" {
  description = "RDS DB UserName"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS DB Password"
  type        = string
  default     = "admin1234"
}

variable "db_port" {
  description = "RDS DB Port"
  type        = number
  default     = "3306"
}

