variable "aws_region" {
  default     = "eu-north-1"
}

variable "email" {
  default     = "k.polonkiewicz@gmail.com"
}

variable "sns_subscription_email_address_list" {
   type = list(string)
   description = "List of email addresses"
 }
 
 variable "sns_subscription_protocol" {
   type = string
   default = "email"
   description = "SNS subscription protocal"
 }
 
 variable "sns_topic_name" {
   type = string
   description = "SNS topic name"
 }
 
 variable "sns_topic_display_name" {
   type = string
   description = "SNS topic display name"
 }