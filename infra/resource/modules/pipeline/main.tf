# ==========================================
# 1. AWS Account
# ==========================================

data "aws_caller_identity" "current" {}


# ==========================================
# 2. GitHub Connection
# ==========================================

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.tag_header}github-connection"
  provider_type = "GitHub"
}


# ==========================================
# 3. Pipeline Artifact S3 Bucket
# ==========================================

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.tag_header}pipeline-artifacts-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = {
    Name = "${var.tag_header}pipeline-artifacts"
  }
}


resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ==========================================
# 4. CodePipeline IAM Role
# ==========================================

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.tag_header}codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codepipeline.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.tag_header}codepipeline-service-role"
  }
}


# ==========================================
# 5. CodePipeline IAM Policy
# ==========================================

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.tag_header}codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]

        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "codeconnections:UseConnection",
          "codestar-connections:UseConnection"
        ]

        Resource = aws_codestarconnections_connection.github.arn
      }
    ]
  })
}


# ==========================================
# 6. CodePipeline
# ==========================================

resource "aws_codepipeline" "pipeline" {
  name     = "${var.tag_header}asg-cicd-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }


  # ----------------------------------------
  # Source
  # GitHub 소스 가져오기
  # ----------------------------------------

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"

      output_artifacts = [
        "source_output"
      ]

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github.arn

        FullRepositoryId = var.github_repository

        BranchName = var.github_branch

        OutputArtifactFormat = "CODE_ZIP"

        DetectChanges = "false"
      }
    }
  }


  # ----------------------------------------
  # Deploy
  # CodeDeploy 실행
  # ----------------------------------------

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "CodeDeploy"
      version  = "1"

      input_artifacts = [
        "source_output"
      ]

      configuration = {
        ApplicationName = var.codedeploy_application_name

        DeploymentGroupName = var.codedeploy_deployment_group_name
      }
    }
  }
}
