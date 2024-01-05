# resource "kubectl_manifest" "aws-observability" {
#   yaml_body = <<-YAML
#     ---
#     apiVersion: v1
#     kind: Namespace
#     metadata:
#       name: aws-observability
#   YAML
# }

# resource "kubectl_manifest" "aws-logging" {
#   yaml_body  = <<-YAML
#     kind: ConfigMap
#     apiVersion: v1
#     metadata:
#       name: aws-logging
#       namespace: aws-observability
#     data:
#       flb_log_cw: "false"  # Set to true to ship Fluent Bit process logs to CloudWatch.
#       filters.conf: |
#         [FILTER]
#             Name parser
#             Match *
#             Key_name log
#             Parser crio
#         [FILTER]
#             Name kubernetes
#             Match kube.*
#             Merge_Log On
#             Keep_Log Off
#             Buffer_Size 0
#             Kube_Meta_Cache_TTL 300s
#       output.conf: |
#         [OUTPUT]
#             Name cloudwatch_logs
#             Match   kube.*
#             region ${local.region}
#             log_group_name /aws/eks/${module.eks.cluster_name}/cluster
#             log_stream_prefix from-fluent-bit-
#             log_retention_days 60
#             auto_create_group true
#       parsers.conf: |
#         [PARSER]
#             Name crio
#             Format Regex
#             Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
#             Time_Key    time
#             Time_Format %Y-%m-%dT%H:%M:%S.%L%z
#   YAML
#   depends_on = [kubectl_manifest.aws-observability]
# }
