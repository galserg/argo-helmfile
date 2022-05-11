# Intro

Support for `helmfile` with `argo-cd`.

Fork https://github.com/travisghansen/argo-cd-helmfile

WITHOUT helm2 and init

# Envs for job
```
HELMFILE_BINARY - custom path to helmfile binary
HELMFILE_GLOBAL_OPTIONS - helmfile --help
HELMFILE_TEMPLATE_OPTIONS - helmfile template --help
HELMFILE_FILE - file for deploy (-f options)
HELMFILE_ENV - env (-e options)
```

#Helmfile ARGO tune

```
  server:
    configEnabled: true
    config:
      configManagementPlugins: |
        - name: helmfile
          generate:
            command: ["argo-helmfile.sh"]
  repoServer:
    volumeMounts:
      - mountPath: /usr/local/bin/argo-helmfile.sh
        name: custom-tools
        subPath: argo-helmfile.sh
      - mountPath: /usr/local/bin/helmfile
        name: custom-tools
        subPath: helmfile
    volumes:
      - name: custom-tools
        emptyDir: {}
    initContainers:
      - name: download-tools
        image: alpine:3.8
        command: [ sh, -c ]
        args:
          - wget -qO /custom-tools/argo-helmfile.sh https://raw.githubusercontent.com/galserg/argo-helmfile/master/src/argo-helmfile.sh &&
            chmod +x /custom-tools/argo-helmfile.sh &&
            wget -qO /custom-tools/helmfile https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_amd64 &&
            chmod +x /custom-tools/helmfile
        volumeMounts:
          - mountPath: /custom-tools
            name: custom-tools
```