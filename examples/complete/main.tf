# Complete Example

This example demonstrates how to use the fluentbit-configuration module with multiple technologies and custom configurations.

## Basic Usage

```hcl
module "log_config" {
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

# Use outputs in your ECS container definitions module
module "container_definitions" {
  source = "Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"

  log_config_parsers = module.log_config.log_config_parsers
  log_config_filters = module.log_config.log_config_filters

  # ... other configuration
}
```

## Advanced Usage with Custom Parsers and Filters

```hcl
module "log_config" {
  source = "../../"

  name = "my-service"

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
      name      = "envoy" # No container specified, uses wildcard
    }
  ]

  # Add custom parser for application-specific format
  custom_parsers = [
    {
      name   = "custom_app_json"
      format = "json"
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

  # Add custom filters for enrichment
  custom_filters = [
    {
      name  = "modify"
      match = "*"
      add_fields = {
        environment = "production"
        service     = "my-service"
        team        = "platform"
      }
    },
    {
      name    = "grep"
      match   = "container-app-*"
      regex   = "level (ERROR|CRITICAL)"
    }
  ]
}
```

## Single Technology Example

```hcl
module "log_config" {
  source = "../../"

  name = "api-service"

  log_sources = [
    {
      name      = "dotnet"
      container = "api"
    }
  ]
}
```

## Multiple Containers Same Technology

```hcl
module "log_config" {
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
```

## Output Structure

The module outputs are ready to use with the container definitions module:

```hcl
output "log_config_parsers" {
  # List of parser objects matching the log_config_parsers variable structure
  value = module.log_config.log_config_parsers
}

output "log_config_filters" {
  # List of filter objects matching the log_config_filters variable structure
  value = module.log_config.log_config_filters
}
```
