# Copyright (c) 2013, Groupon, Inc.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rugged'
require 'grit'

require File.expand_path('../bugwatch/adapters', __FILE__)
require File.expand_path('../bugwatch/analysis', __FILE__)
require File.expand_path('../bugwatch/attrs', __FILE__)
require File.expand_path('../bugwatch/complexity_score', __FILE__)
require File.expand_path('../bugwatch/diff_parser', __FILE__)
require File.expand_path('../bugwatch/ruby_complexity', __FILE__)
require File.expand_path('../bugwatch/churn', __FILE__)
require File.expand_path('../bugwatch/commit', __FILE__)
require File.expand_path('../bugwatch/diff', __FILE__)
require File.expand_path('../bugwatch/exception_data', __FILE__)
require File.expand_path('../bugwatch/exception_tracker', __FILE__)
require File.expand_path('../bugwatch/flog_score', __FILE__)
require File.expand_path('../bugwatch/import', __FILE__)
require File.expand_path('../bugwatch/method_parser', __FILE__)
require File.expand_path('../bugwatch/repo', __FILE__)
require File.expand_path('../bugwatch/tag', __FILE__)
require File.expand_path('../bugwatch/tree', __FILE__)
