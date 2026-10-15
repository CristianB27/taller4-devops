#!/usr/bin/env bash
# Uso: bash health-check.sh <url_base> <ambiente_esperado> <version_esperada>
set -euo pipefail

URL="${1:?Falta la URL base}"
EXPECTED_ENV="${2:?Falta el ambiente esperado}"
EXPECTED_VERSION="${3:?Falta la versión (SHA) esperada}"
MAX_ATTEMPTS=30
SLEEP_SECONDS=10

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  body="$(curl -fsS --max-time 10 "${URL}/health" 2>/dev/null || true)"

  if [[ -n "$body" ]] \
     && [[ "$(jq -r '.status' <<<"$body" 2>/dev/null)" == "ok" ]] \
     && [[ "$(jq -r '.environment' <<<"$body" 2>/dev/null)" == "$EXPECTED_ENV" ]] \
     && [[ "$(jq -r '.version' <<<"$body" 2>/dev/null)" == "$EXPECTED_VERSION" ]]; then
    echo "✅ ${URL} saludable: ambiente=${EXPECTED_ENV}, versión=${EXPECTED_VERSION}"
    exit 0
  fi

  echo "Intento ${attempt}/${MAX_ATTEMPTS}: aún no está listo (respuesta: ${body:-sin respuesta}). Reintento en ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
done

echo "❌ La prueba de disponibilidad falló para ${URL}"
exit 1
