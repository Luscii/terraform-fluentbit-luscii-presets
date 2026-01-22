################################################################################
# Example 1: Basic Multi-Technology Setup
################################################################################

module "log_config_basic" {
  source = "../../"

  name = "my-service"

  log_sources = [
    {
      name      = "php"
      container = "app"
    },
    {
      name      = "nginx"
      container = "web"
    }
  ]
}

################################################################################
# Example 2: Advanced Setup with Custom Configuration
################################################################################

module "log_config_advanced" {
  source = "../../"

  name    = "advanced-service"
  context = module.label.context

  # Standard technology configurations
  log_sources = [
    {
      name      = "php"
      container = "app"
    },
    {
      name      = "php"
      container = "worker"
    },
    {
      name      = "nginx"
      container = "web"
    },
    {
      name      = "datadog"
      container = "datadog-agent"
    }
  ]

  # Add custom parser for application-specific format
  custom_parsers = [
    {
      name        = "custom_app_json"
      format      = "json"
      time_key    = "timestamp"
      time_format = "%Y-%m-%dT%H:%M:%S.%LZ"
      time_keep   = true
      filter = {
        match        = "container-app-*"
        key_name     = "message"
        reserve_data = true
        preserve_key = false
      }
    }
  ]

  # Add custom filters for enrichment and additional filtering
  custom_filters = [
    # Enrich all logs with environment metadata
    {
      name  = "modify"
      match = "*"
      add_fields = {
        environment = "production"
        service     = "my-service"
        team        = "platform"
      }
    },
    # Only keep ERROR and CRITICAL logs from app container
    {
      name  = "grep"
      match = "container-app-*"
      regex = "level (ERROR|CRITICAL)"
    },
    # Exclude health check requests from nginx
    {
      name    = "grep"
      match   = "container-web-*"
      exclude = "request_uri /health"
    }
  ]
}

################################################################################
# Example 3: Multi-Worker PHP Setup
################################################################################

module "log_config_workers" {
  source = "../../"

  name = "worker-service"

  # PHP application with multiple worker types
  log_sources = [
    {
      name      = "php"
      container = "queue-worker"
    },
    {
      name      = "php"
      container = "cron-worker"
    },
    {
      name      = "php"
      container = "scheduler"
    }
  ]
}

################################################################################
# Supporting Resources
################################################################################

# CloudPosse label module for consistent naming
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "luscii"
  environment = "prod"
  name        = "example-service"
  attributes  = ["ecs"]

  tags = {
    ManagedBy = "terraform"
    Example   = "complete"
  }
}

################################################################################
# Integration Example with Container Definitions
################################################################################

# This shows how you would use the log configuration with the container definitions module
# Uncomment and configure when deploying to actual ECS

# module "container_definitions" {
#   source  = "Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"
#   version = "~> 0.1.8"
#
#   # Pass the log configuration outputs
#   log_config_parsers = module.log_config_advanced.log_config_parsers
#   log_config_filters = module.log_config_advanced.log_config_filters
#
#   # Other container configuration...
#   container_name   = "app"
#   container_image  = "my-app:latest"
#   container_cpu    = 256
#   container_memory = 512
#
#   # Environment variables, secrets, etc.
# }
