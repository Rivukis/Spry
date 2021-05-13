#!/bin/sh

script_full_path=$(dirname "$0")

sourcery --sourcesPath ./ \
--output ./TestHelpers/ \
--templates ${script_full_path}
