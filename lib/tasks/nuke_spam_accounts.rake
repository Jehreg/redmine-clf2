# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
# nuke_spam_accounts.rake - Redmine Task
# Copyright (C) 2010 Patrick Naubert
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'active_record'
require 'iconv'
require 'pp'

namespace :redmine do
  desc 'Spam accounts removal'
  task :spam_accounts_removal => :environment do

    # Delete all non-active records that have been created more than 7 days ago
    User.delete_all(["status = 2 AND last_login_on is NULL AND created_on < ?",Date.today-7])
  end
end

