case "${OSTYPE}" in
  darwin*) SHELL_SESSIONS_DISABLE=1 ;;
  linux*) skip_global_compinit=1 ;;
  *) ;;
esac
