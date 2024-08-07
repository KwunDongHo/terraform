# Local Variable 정의
locals {
  ssh_port      = 22
  http_port     = 80
  https_port    = 443
  db_port       = 3306
  redis_port    = 6379
  efs_port      = 2049
  any_port      = 0
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  icmp_protocol = "icmp"
  all_network   = "0.0.0.0/0"
}