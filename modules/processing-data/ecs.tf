
locals {
  container_name = "video-processing-container"
}

#################################
# ECS Cluster
#################################
resource "aws_ecs_cluster" "video_processing" {
  name = "video-processing"
  tags = var.common_tags
}


#################################
# ECS Task Definition
#################################
resource "aws_ecs_task_definition" "video_processing" {
  family                   = "video-processing"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 6144




  depends_on = [
    aws_ecs_cluster.video_processing
  ]

  container_definitions = jsonencode([
    {
      name   = local.container_name
      image  = var.ecs_video_image
      cpu    = 2048
      memory = 6144

      # Logging Configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/video-processing"
          "awslogs-region"        = "ap-southeast-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
          "max-buffer-size"       = "25m"
          "mode"                  = "non-blocking"
        }
      }

      # Port Mapping Configuration
      portMappings = [
        {
          containerPort = 80 
          hostPort      = 80 
          protocol      = "tcp"
        },
        {
          containerPort = 443 
          hostPort      = 443 
          protocol      = "tcp"
        }
      ]


      essential = true
      environment = [
        {
          name  = "S3_BUCKET"
          value = "your-bucket-name"
        },
        {
          name  = "INPUT_VIDEO_KEY"
          value = "your-video-key"
        }
      ]
    }
  ])
}
