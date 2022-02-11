# /*
# MIT License
#
# Copyright (c) [2022] [CloudSEN12 team]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Set parameters
Sys.setenv(
  GCE_AUTH_FILE="/home/csaybar/cloudsen12-310113-6b317fcd409c.json",
  GCE_DEFAULT_PROJECT_ID="cloudsen12-310113",
  GCE_DEFAULT_ZONE="us-central1-a"
)

library(googleComputeEngineR)

# --------------------------------------------------------------------
# CREATE CLUSTER -----------------------------------------------------
# --------------------------------------------------------------------
for (index in 1:100) {
  vm <- gce_vm(
    template = "rstudio",
    name = sprintf("zfmaskpc%02d", index),
    username = "cloudsen12",
    password = "lab",
    predefined_type = "e2-highcpu-8",
    dynamic_image = "csaybar/fmask"
  )
}

# gce_tag_container()
# gce_list_instances()
