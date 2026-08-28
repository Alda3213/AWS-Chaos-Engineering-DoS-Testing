variable "aws_region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "Rango de IPs principal para la VPC"
  default     = "10.0.0.0/16"
}

variable "mi_ip_publica" {
  type        = string
  description = "Tu dirección IP pública para restringir el acceso SSH (Formato: X.X.X.X/32)"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2 para los servidores de la aplicación"
  default     = "t3.micro"
}

variable "asg_min_size" {
  type        = number
  description = "Cantidad mínima de servidores en el Auto Scaling Group"
  default     = 1
}

variable "asg_max_size" {
  type        = number
  description = "Cantidad máxima de servidores permitidos bajo estrés"
  default     = 4
}

variable "asg_desired_capacity" {
  type        = number
  description = "Cantidad inicial de servidores que se encenderán"
  default     = 2
}

