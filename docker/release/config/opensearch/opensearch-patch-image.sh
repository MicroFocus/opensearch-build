# Patches vulnerable jars in OpenSearch 1.3.6 distribution
OPENSEARCH_HOME=$1
TEMP_DIR=/tmp/opensearch
mkdir -p $TEMP_DIR

COMMONS_TEXT_VER=1.10.0
JACKSON_VER=2.13.4
JACKSON_DATABIND_VER=2.13.4.2
WOODSTOX_VER=6.4.0

MAVEN_URL=https://repo1.maven.org/maven2
curl -o $TEMP_DIR/commons-text-${COMMONS_TEXT_VER}.jar $MAVEN_URL/org/apache/commons/commons-text/${COMMONS_TEXT_VER}/commons-text-${COMMONS_TEXT_VER}.jar
curl -o $TEMP_DIR/jackson-databind-${JACKSON_DATABIND_VER}.jar $MAVEN_URL/com/fasterxml/jackson/core/jackson-databind/${JACKSON_DATABIND_VER}/jackson-databind-${JACKSON_DATABIND_VER}.jar
curl -o $TEMP_DIR/jackson-annotations-${JACKSON_VER}.jar $MAVEN_URL/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VER}/jackson-annotations-${JACKSON_VER}.jar
curl -o $TEMP_DIR/jackson-core-${JACKSON_VER}.jar $MAVEN_URL/com/fasterxml/jackson/core/jackson-core/${JACKSON_VER}/jackson-core-${JACKSON_VER}.jar
curl -o $TEMP_DIR/woodstox-core-${WOODSTOX_VER}.jar  $MAVEN_URL/com/fasterxml/woodstox/woodstox-core/${WOODSTOX_VER}/woodstox-core-${WOODSTOX_VER}.jar

# Replace all known vulnerable jars
rm -f $OPENSEARCH_HOME/plugins/opensearch-ml/commons-text-*.jar
cp $TEMP_DIR/commons-text-${COMMONS_TEXT_VER}.jar $OPENSEARCH_HOME/plugins/opensearch-ml/
rm -f $OPENSEARCH_HOME/plugins/opensearch-security/woodstox-core-*.jar
cp $TEMP_DIR/woodstox-core-${WOODSTOX_VER}.jar $OPENSEARCH_HOME/plugins/opensearch-security/

rm -f $OPENSEARCH_HOME/performance-analyzer-rca/lib/jackson-core-*.jar
cp $TEMP_DIR/jackson-core-${JACKSON_VER}.jar $OPENSEARCH_HOME/performance-analyzer-rca/lib/
rm -f $OPENSEARCH_HOME/performance-analyzer-rca/lib/jackson-annotations-*.jar
cp $TEMP_DIR/jackson-annotations-${JACKSON_VER}.jar $OPENSEARCH_HOME/performance-analyzer-rca/lib/

for dir in plugins/opensearch-anomaly-detection plugins/opensearch-ml plugins/opensearch-sql plugins/opensearch-performance-analyzer plugins/opensearch-security modules/ingest-geoip performance-analyzer-rca/lib lib/tools/upgrade-cli
do 
  rm -f  $OPENSEARCH_HOME/$dir/jackson-databind-*.jar
  cp $TEMP_DIR/jackson-databind-${JACKSON_DATABIND_VER}.jar $OPENSEARCH_HOME/$dir/
done
