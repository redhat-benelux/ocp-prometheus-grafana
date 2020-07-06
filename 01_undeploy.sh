
source ./project.env

oc delete -f rbac.yml
oc delete project ${MONITOR_PROJECT}
oc delete project ${APP_PROJECT_A}
oc delete project ${APP_PROJECT_B}


