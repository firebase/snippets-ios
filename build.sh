function build_sample() {
  SAMPLE=$1
  WORKSPACE=$2

  echo "Building $SAMPLE"
  cd $SAMPLE && pod install ; cd -

  set -o pipefail && xcodebuild \
    -workspace ${SAMPLE}/${WORKSPACE}.xcworkspace \
    -scheme ${WORKSPACE} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 7' \
    build \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    | xcpretty

  cd $SAMPLE && pod deintegrate ; cd -
  echo "Done!"
}

build_sample "database" "DatabaseReference"
build_sample "storage" "StorageReference"
build_sample "firoptions/FiroptionConfiguration" "FiroptionConfiguration"