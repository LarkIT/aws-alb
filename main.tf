
resource "aws_alb" "appserver" {
  name                       = "${var.host_prefix}-${var.environment}app-lb"
  internal                   = false
  ip_address_type            = "ipv4"
  security_groups            = ["${var.security_groups}"]
  subnets                    = ["${var.subnets}"]
#  enable_deletion_protection = true
  enable_deletion_protection = false
  idle_timeout               = "600"
  #access_logs {
  #  bucket="..."
  #  prefix="prodapp-lb"
  #}
  tags {
    Environment = "${var.environment}"
  }
}

# Target Groups
resource "aws_alb_target_group" "app-http" {
  name     = "${var.host_prefix}-${var.environment}-app-http"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"
}

resource "aws_alb_target_group" "app-https" {
  name     = "${var.host_prefix}-${var.environment}-app-https"
  vpc_id   = "${var.vpc_id}"
  port     = 443
  protocol = "HTTPS"
}

# Listeners
# - http://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
resource "aws_alb_listener" "app-http" {
  load_balancer_arn = "${aws_alb.appserver.arn}"
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.app-http.arn}"
    type = "forward"
  }
}

data "aws_acm_certificate" "app_cert" {
  count    = "${var.app_ssl_enable}"
  domain   = "${var.app_ssl_domain}"
  statuses = ["ISSUED"]
}

resource "aws_alb_listener" "app-https" {
  count             = "${var.app_ssl_enable}"
  load_balancer_arn = "${aws_alb.appserver.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${data.aws_acm_certificate.app_cert.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.app-https.arn}"
    type = "forward"
  }
}

#resource "aws_alb_target_group_attachment" "stageapp" {
#  count = "${length(var.app_target_groups)}"
  # The following line is replacing the * in the stageapp object string with the resulting index of the target group that matches the "Name" tag,
  # which can only be built by doing a final lookup on the target groups suffix to properly rebuild the name, to get the right index to complete
  # the * replacement on the arn object string.
#  target_group_arn = "${aws_alb_target_group.stageapp.*.arn[index(aws_alb_target_group.stageapp.*.tags.Name, "${var.host_prefix}-stageapp-${lookup(var.app_target_groups[count.index], "suffix")}")]}"
#  target_id        = "${aws_instance.stageapp-01.id}"
#}

#resource "aws_alb_target_group_attachment" "app-http" {
#  target_group_arn = "${aws_alb_target_group.app-http.arn}"
#  target_id        = "${var.hostnames}"
#}

resource "aws_route53_record" "app-lb-ext" {
  count   = "${var.external_dns_enable}"
  zone_id = "${var.route53_external_id}"
  name    = "${var.external_domain_name}"
  type    = "A"
  alias {
    name = "${aws_alb.appserver.dns_name}"
    zone_id = "${aws_alb.appserver.zone_id}"
    evaluate_target_health = false
  }
}
