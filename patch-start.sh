#!/bin/bash
if ! grep -q "env-vars" start-pentaho.sh; then
  echo "Inserting environment variables declaration to start-pentaho.sh"
  cp start-pentaho.sh start-pentaho.sh.BKP
  sed -i '/^\s*sh startup\.sh/i \ \ . "\$DIR/env-vars.sh"\n  export CATALINA_OPTS="\$CATALINA_OPTS \$E_OPTS"' start-pentaho.sh 
else
  echo "start-pentaho.sh was already patched"
fi
