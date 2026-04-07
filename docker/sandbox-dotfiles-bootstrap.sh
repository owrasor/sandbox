#!/usr/bin/env bash
# Executa um script opcional do mount de dotfiles no máximo uma vez com sucesso
# (marcador em /home/dev/workspace/.sandbox/). Sempre termina com exit 0 para não
# bloquear o arranque do zsh. Ver docs/sandbox.md.

set -euo pipefail

readonly DOTFILES_ROOT=/home/dev/dotfiles
readonly WORKSPACE_ROOT=/home/dev/workspace
readonly STATE_REL=.sandbox
readonly MARKER_NAME=dotfiles-bootstrap.done
readonly LOCK_NAME=dotfiles-bootstrap.lock

log_err() { printf '%s\n' "sandbox-dotfiles-bootstrap: $*" >&2; }

# Opcional: desactivar toda a funcionalidade (CI / depuração)
if [[ -n "${SANDBOX_DOTFILES_BOOTSTRAP_SKIP:-}" ]]; then
  exit 0
fi

raw_name="${DOTFILES_BOOTSTRAP_SCRIPT:-}"
# trim leading/trailing whitespace (bash)
name="${raw_name#"${raw_name%%[![:space:]]*}"}"
name="${name%"${name##*[![:space:]]}"}"

if [[ -z "$name" ]]; then
  exit 0
fi

if [[ "$name" == "." || "$name" == ".." ]]; then
  log_err "nome de script inválido: ${name@Q}"
  exit 0
fi

if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  log_err "nome de script inválido (use apenas [a-zA-Z0-9._-], sem /): ${name@Q}"
  exit 0
fi

state_dir="${WORKSPACE_ROOT}/${STATE_REL}"
marker="${state_dir}/${MARKER_NAME}"
lock_file="${state_dir}/${LOCK_NAME}"

if [[ -f "$marker" ]]; then
  exit 0
fi

if ! mkdir -p "$state_dir" 2>/dev/null; then
  log_err "não foi possível criar ${state_dir@Q} (workspace montado e gravável?)"
  exit 0
fi

candidate="${DOTFILES_ROOT}/${name}"

if [[ ! -f "$candidate" ]]; then
  log_err "ficheiro de bootstrap não encontrado em dotfiles: ${candidate@Q}"
  exit 0
fi

if [[ ! -r "$candidate" ]]; then
  log_err "ficheiro de bootstrap sem permissão de leitura: ${candidate@Q}"
  exit 0
fi

resolved="$(realpath "$candidate")"
# Destino real tem de permanecer sob DOTFILES_ROOT (bloqueia symlinks para fora)
case "$resolved" in
  "${DOTFILES_ROOT}" | "${DOTFILES_ROOT}/"*) ;;
  *)
    log_err "recusa por segurança: caminho resolvido fora de ${DOTFILES_ROOT@Q}: ${resolved@Q}"
    exit 0
    ;;
esac

exec_lock() {
  local code=0
  (
    flock 200
    if [[ -f "$marker" ]]; then
      exit 0
    fi
    set +e
    # shellcheck disable=SC1090
    bash --noprofile --norc "$resolved"
    code=$?
    set -e
    if (( code == 0 )); then
      tmp="${marker}.$$.tmp"
      if printf '%s\n' "ok $(date -Iseconds 2>/dev/null || date)" >"$tmp" 2>/dev/null; then
        mv -f "$tmp" "$marker"
      else
        rm -f "$tmp"
        log_err "não foi possível gravar o marcador em ${marker@Q}"
      fi
    else
      log_err "script ${name@Q} terminou com código ${code}; marcador de sucesso não gravado — corrige e volta a arrancar"
    fi
  ) 200>"$lock_file"
}

exec_lock
exit 0
