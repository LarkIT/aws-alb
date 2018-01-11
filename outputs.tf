output "app-http_arn" {
  value = "${aws_alb_target_group.app-http.arn}"
}

output "app-https_arn" {
  value = "${aws_alb_target_group.app-https.arn}"
}
