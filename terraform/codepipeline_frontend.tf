resource "aws_codebuild_project" "frontend" {
  name         = "vka-front-end-build"
  service_role = "arn:aws:iam::555399571935:role/service-role/codebuild-vka-front-end-build-service-role"

  artifacts {
    encryption_disabled    = false
    name                   = "vka-front-end-build"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  source {
    buildspec           = "buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

}

resource "aws_codepipeline" "frontend" {
  name     = "vka-frontend-pipeline"
  role_arn = "arn:aws:iam::555399571935:role/service-role/AWSCodePipelineServiceRole-us-east-2-vka-codepipeline"
  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "BranchName"           = "main"
        "ConnectionArn"        = "arn:aws:codeconnections:us-east-2:555399571935:connection/2b136816-3f14-47d1-9a2b-02467e69933b"
        "DetectChanges"        = "true"
        "FullRepositoryId"     = "vietnguyen24/react-shopping-cart"
        "OutputArtifactFormat" = "CODE_ZIP"
      }
      input_artifacts = []
      name            = "Source"
      namespace       = "SourceVariables"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      role_arn  = null
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "REACT_APP_COGNITO_DOMAIN"
              type  = "PLAINTEXT"
              value = "${data.aws_region.current.name}-vka.auth.${data.aws_region.current.name}.amazoncognito.com"
            },
            {
              name  = "REACT_APP_COGNITO_CLIENT_ID"
              type  = "PLAINTEXT"
              value = aws_cognito_user_pool_client.userpool_client.id
              #value = awsc
            },
            {
              name  = "REACT_APP_COGNITO_LOGOUT_REDIRECT_URI"
              type  = "PLAINTEXT"
              value = "https://${aws_cloudfront_distribution.frontend_cache.domain_name}"
            },
            {
              name  = "REACT_APP_COGNITO_LOGIN_REDIRECT_URI"
              type  = "PLAINTEXT"
              value = "https://${aws_cloudfront_distribution.frontend_cache.domain_name}/callback"
            },
            {
              name  = "REACT_APP_AWS_REGION"
              type  = "PLAINTEXT"
              value = data.aws_region.current.name
            },
            {
              name  = "REACT_APP_API_GATEWAY_ORIGIN"
              type  = "PLAINTEXT"
              value = "https://${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev"
            },
            {
              name  = "REACT_APP_IMAGE_ORIGIN"
              type  = "PLAINTEXT"
              value = "https://${aws_s3_bucket.images.bucket_regional_domain_name}"
            },
          ]
        )
        "ProjectName" = "vka-front-end-build"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name      = "Build"
      namespace = "BuildVariables"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      role_arn  = null
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = "vka-frontend"
        "Extract"    = "true"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      namespace        = "DeployVariables"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }


}

