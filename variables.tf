variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "host_prefix" {
  description = "Hostname prefix (abc)"
}

variable "security_groups" {
  description = "The name of our environment, i.e. development."
  type        = "list"
  default     = []
}

variable "subnets" {
  description = "Hostname prefix (abc)"
  type        = "list"
}

variable "app_target_groups" {
  type = "list"
  default = [
    {
      suffix   = "default-http"
      port     = "80",
      protocol = "HTTPS"
    },
    {
      suffix   = "default-https"
      port     = "443",
      protocol = "HTTPS"
    }
  ]
}

variable "vpc_id" {
  description = "The AWS unique identifier for the vpc."
}

#variable "hostnames" {
#  description = "Hostname prefix (abc)"
#}

variable "app_ssl_domain" {
  description = "SSL Certificate Domain Name for App ALB"
  default     = "www.terraform.lark-it.com"
}

variable "app_ssl_enable" {
  description = "Enable SSL for app Load Balancer - ACM Cert needs to be already issued!"
  default     = false
}

variable "external_dns_enable" {
  description = "Enable management of external DNS Domain Name (Route53) (true/false)"
  default = true
}

variable "external_domain_name" {
  default = "aws.lark-it.com"
}

variable "route53_external_id" {
  description = "DNS external name id"
}

variable "health_check_conf" {
  description = "Parameters to configure health checks for the load balancer target group"
  type = "map"

  default = {
    interval = "30"
    path = "/"
    port = "traffic-port"
    timeout = "5"
    healthy_threshold= "3"
    unhealthy_threshold = "3"
    matcher = "200"
  }
}