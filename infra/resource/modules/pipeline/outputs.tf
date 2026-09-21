output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}

output "artifact_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  value = aws_codestarconnections_connection.github.connection_status
}
