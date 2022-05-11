#!/bin/bash

## specially handled ENV vars
# HELM_BINARY - custom path to helm binary
# HELM_TEMPLATE_OPTIONS - helm template --help
# HELMFILE_BINARY - custom path to helmfile binary
# HELMFILE_GLOBAL_OPTIONS - helmfile --help
# HELMFILE_TEMPLATE_OPTIONS - helmfile template --help
# HELMFILE_HELMFILE - a complete helmfile.yaml (ignores standard helmfile.yaml and helmfile.d if present based on strategy)
# HELMFILE_HELMFILE_STRATEGY - REPLACE or INCLUDE
# HELMFILE_INIT_SCRIPT_FILE - path to script to execute during the init phase
# HELM_DATA_HOME - perform variable expansion

# NOTE: only 1 -f value/file/dir is used by helmfile, while you can specific -f multiple times
# only the last one matters and all previous -f arguments are irrelevant

# NOTE: helmfile pukes if both helmfile.yaml and helmfile.d are present (and -f isn't explicity used)

## standard build environment
## https://argoproj.github.io/argo-cd/user-guide/build-environment/
# ARGOCD_APP_NAME - name of application
# ARGOCD_APP_NAMESPACE - destination application namespace.
# ARGOCD_APP_REVISION - the resolved revision, e.g. f913b6cbf58aa5ae5ca1f8a2b149477aebcbd9d8
# ARGOCD_APP_SOURCE_PATH - the path of the app within the repo
# ARGOCD_APP_SOURCE_REPO_URL the repo's URL
# ARGOCD_APP_SOURCE_TARGET_REVISION - the target revision from the spec, e.g. master.

# each manifest generation cycle calls git reset/clean before (between init and generate it is NOT ran)
# init is called before every manifest generation
# it can be used to download dependencies, etc, etc

# does not have "v" in front
# KUBE_VERSION="<major>.<minor>"
# KUBE_API_VERSIONS="v1,apps/v1,..."

set -e
set -x

echoerr() { printf "%s\n" "$*" >&2; }


SCRIPT_NAME=$(basename "${0}")


if [[ ! -d "/tmp/__${SCRIPT_NAME}__/bin" ]]; then
  mkdir -p "/tmp/__${SCRIPT_NAME}__/bin"
fi


if [[ "${HELMFILE_BINARY}" ]]; then
  helmfile="${HELMFILE_BINARY}"
else
  if [[ $(which helmfile) ]]; then
    helmfile="$(which helmfile)"
  else
    LOCAL_HELMFILE_BINARY="/tmp/__${SCRIPT_NAME}__/bin/helmfile"
    if [[ ! -x "${LOCAL_HELMFILE_BINARY}" ]]; then
      wget -O "${LOCAL_HELMFILE_BINARY}" "https://github.com/roboll/helmfile/releases/download/v0.138.7/helmfile_linux_amd64"
      chmod +x "${LOCAL_HELMFILE_BINARY}"
    fi
    helmfile="${LOCAL_HELMFILE_BINARY}"
  fi
fi

if [[ "${ARGOCD_APP_NAMESPACE}" ]]; then
  helmfile="${helmfile} --namespace ${ARGOCD_APP_NAMESPACE}"
fi

if [[ "${HELMFILE_GLOBAL_OPTIONS}" ]]; then
  helmfile="${helmfile} ${HELMFILE_GLOBAL_OPTIONS}"
fi

echoerr "$(${helmfile} --version)"
echoerr "$(env)"


${helmfile} -e rpod -f producer.yaml \
  template \
  --skip-deps ${INTERNAL_HELMFILE_TEMPLATE_OPTIONS} \
  ${HELMFILE_TEMPLATE_OPTIONS}

