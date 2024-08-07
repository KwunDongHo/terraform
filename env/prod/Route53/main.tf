terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Prod/Route53/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}


# 1. 호스팅 영역 생성 배포
resource "aws_route53_zone" "sportslinkdev_shop" {
  name    = "sportslinkdev.shop"
  comment = "sportslinkdev_shop"
}


# #2. 1번 배포 후 2번 주석 해제 후 ACM 인증서 생성 배포
# resource "aws_acm_certificate" "sportslinkdev_shop" {
#   domain_name               = "sportslinkdev.shop"
#   subject_alternative_names = ["*.sportslinkdev.shop"]
#   validation_method         = "DNS"

#   tags = {
#     Name = "sportslinkdev_shop certificate"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# #3. 2번 배포 후 3번 주석 해제 후 DNS 검증 레코드 생성 배포
# resource "aws_route53_record" "sportslinkdev_shop_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.sportslinkdev_shop.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   zone_id         = aws_route53_zone.sportslinkdev_shop.zone_id
#   name            = each.value.name
#   type            = each.value.type
#   ttl             = 60
#   records         = [each.value.record]
# }

# #4. 3번 배포 후 4번 주석 해제 후 ACM 인증서 검증 배포
# resource "aws_acm_certificate_validation" "sportslinkdev_shop" {
#   certificate_arn = aws_acm_certificate.sportslinkdev_shop.arn
#   validation_record_fqdns = [
#     for record in aws_route53_record.sportslinkdev_shop_validation : record.fqdn
#   ]
# }