# output "otel_collector_external_ip" {
#   description = "External IP of the SigNoz OTEL Collector Service"
#   value       = data.kubernetes_service.otel_collector.status[0].load_balancer[0].ingress[0].ip
# }

# output "otel_collector_grpc_endpoint" {
#   description = "gRPC endpoint for OTEL Collector"
#   value       = "grpc://${data.kubernetes_service.otel_collector.status[0].load_balancer[0].ingress[0].ip}:4317"
# }

# output "otel_collector_http_endpoint" {
#   description = "HTTP endpoint for OTEL Collector"
#   value       = "http://${data.kubernetes_service.otel_collector.status[0].load_balancer[0].ingress[0].ip}:4318"
# }
