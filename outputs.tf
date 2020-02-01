# NGFW MGMT IP
output "eip_for_NGFW" {
  description = "EIP or Public address for the NGFW"
  value       = aws_eip_association.ngfw.public_ip
}

# NGFW Web Application IP
output "eip_for_Web_Application" {
  description = "EIP or Public address for the Web Application Server"
  value       = aws_eip_association.ngfw-web.public_ip
}

# BIGIP MGMT IP
output "eip_for_BIGIP" {
  description = "EIP or Public address for the BIGIP"
  value       = aws_eip_association.bigip.public_ip
}

# Web Server MGMT IP
#output "eip_for_Web_Server" {
#  description = "EIP or Public address for the Web Server"
#  value       = aws_eip_association.web.public_ip
#}
