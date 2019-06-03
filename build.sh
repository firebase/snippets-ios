#
#  Copyright (c) 2017 Google Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

function build_sample() {
  SAMPLE=$1
  WORKSPACE=$2
  SCHEME=$3

  echo "Building $SAMPLE"
  cd $SAMPLE && pod install ; cd -

  set -o pipefail && xcodebuild \
    -workspace ${SAMPLE}/${WORKSPACE}.xcworkspace \
    -scheme ${SCHEME} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone XR' \
    build \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_REQUIRED=NO \
    | xcpretty

  cd $SAMPLE && pod deintegrate ; cd -
  echo "Done!"
}

build_sample "database" "DatabaseReference" "DatabaseReference"
build_sample "storage" "StorageReference" "StorageReference"
build_sample "firoptions/FiroptionConfiguration" "FiroptionConfiguration" "FiroptionConfiguration"
build_sample "firestore/objc" "firestore-smoketest-objc" "firestore-smoketest-objc"
build_sample "firestore/swift" "firestore-smoketest" "firestore-smoketest"
build_sample "dl-invites-sample" "InvitesSample" "InvitesSample"
build_sample "dl-invites-sample" "InvitesSample" "InvitesSampleObjC"
build_sample "inappmessaging" "FIAMReference" "FIAMReferenceSwift"
build_sample "mlkit" "mlkit-snippets" "swift-snippets"
build_sample "mlkit" "mlkit-snippets" "objc-snippets"
