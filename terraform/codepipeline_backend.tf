resource "aws_codebuild_project" "backend" {
  name         = "vka-build-project"
  service_role = "arn:aws:iam::555399571935:role/service-role/codebuild-vka-build-project-service-role"

  artifacts {
    encryption_disabled    = false
    name                   = "vka-build-project"
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
resource "aws_codepipeline" "backend" {
  name     = "vka-codepipeline"
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
        "ConnectionArn"        = "arn:aws:codeconnections:us-east-2:555399571935:connection/65e39569-278a-4cdf-96b8-6693ea3bfaa4"
        "DetectChanges"        = "true"
        "FullRepositoryId"     = "Daisuke-lab/vka-final-backend"
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
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = "vka-build-project"
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
      run_order = 1
      version   = "1"
    }

  }

}