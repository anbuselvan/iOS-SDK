#!/bin/sh
HEADERS_ROOT=$SRCROOT/$PRODUCT_NAME
FRAMEWORK_HEADERS_DIR="$BUILT_PRODUCTS_DIR/$WRAPPER_NAME/Versions/$FRAMEWORK_VERSION/Headers"

## only header files expected at this point
PUBLIC_HEADERS=$(find $FRAMEWORK_HEADERS_DIR/. -not -type d 2> /dev/null | sed -e "s@.*/@@g")

FIND_OPTS=""
for PUBLIC_HEADER in $PUBLIC_HEADERS; do
  if [ -n "$FIND_OPTS" ]; then
    FIND_OPTS="$FIND_OPTS -o"
  fi
  FIND_OPTS="$FIND_OPTS -name '$PUBLIC_HEADER'"
done

if [ -n "$FIND_OPTS" ]; then
  for ORIG_HEADER in $(eval "find $HEADERS_ROOT/. $FIND_OPTS" 2> /dev/null | sed -e "s@^$HEADERS_ROOT/./@@g"); do
    PUBLIC_HEADER=$(basename $ORIG_HEADER)
    RELATIVE_PATH=$(dirname $ORIG_HEADER)
    if [ -e $FRAMEWORK_HEADERS_DIR/$PUBLIC_HEADER ]; then
      mkdir -p "$FRAMEWORK_HEADERS_DIR/$RELATIVE_PATH"
      mv "$FRAMEWORK_HEADERS_DIR/$PUBLIC_HEADER" "$FRAMEWORK_HEADERS_DIR/$RELATIVE_PATH/$PUBLIC_HEADER"
    fi
  done
fi

