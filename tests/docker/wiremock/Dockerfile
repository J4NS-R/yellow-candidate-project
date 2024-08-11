# Used to build ghcr.io/j4ns-r/yellow-candidate-project-telco:latest
FROM wiremock/wiremock:3x
COPY mappings /home/wiremock/mappings/
ENV WIREMOCK_OPTIONS="--port 8080 --max-request-journal-entries 20 --verbose"
EXPOSE 8080
HEALTHCHECK CMD curl -f http://localhost:8080/__admin/mappings || exit 1
