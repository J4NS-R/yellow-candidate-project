[
  {
    "name": "node",
    "image": "ghcr.io/j4ns-r/yellow-candidate-project:${image_tag}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "environment": [
      {
        "name": "VITE_PG_HOST",
        "value": "${pg_host}"
      },
      {
        "name": "VITE_PG_DB",
        "value": "${pg_db}"
      },
      {
        "name": "VITE_PG_USER",
        "value": "${pg_user}"
      },
      {
        "name": "VITE_MIN_AGE",
        "value": "${min_age}"
      },
      {
        "name": "VITE_MAX_AGE",
        "value": "${max_age}"
      },
      {
        "name": "VITE_UPSTREAM_PAYMENT_URL",
        "value": "${upstream_payment_url}"
      },
      {
        "name": "ORIGIN",
        "value": "${origin}"
      },
      {
        "name": "PROTOCOL_HEADER",
        "value": "x-forwarded-proto"
      },
      {
        "name": "PORT_HEADER",
        "value": "x-forwarded-port"
      }
    ],
    "secrets": [
      {
        "name": "VITE_PG_PASS",
        "valueFrom": "${pg_pass_ref}"
      },
      {
        "name": "VITE_API_KEY",
        "valueFrom": "${api_key_ref}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
