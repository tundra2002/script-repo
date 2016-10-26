ubuntu_ver=$(head -1 /etc/issue | awk '{print $2}')
if [ -f /usr/local/bin/ruby ]; then
                ruby_ver=$(/usr/local/bin/ruby -v | awk {'print $2'} | sed 's/p[0-9]*//' 2>/dev/null)
            else
                ruby_ver='xxxxx'
            fi

if [ -f /usr/bin/python ]; then
                python_ver=$(python -c 'import platform; print(platform.python_version())')
            else
                python_ver='xxxxx'
            fi

if [ -f /opt/nginx/sbin/nginx ]; then
                nginx_ver=$(/opt/nginx/sbin/nginx -v 2>&1 >/dev/null | awk '{print $3}' | cut -f2 -d '/' | tail -1) 
            else
                nginx_ver='xxxxx'
            fi

if [ -f /usr/local/bin/tsql ]; then
                tsql_ver=$(tsql -C | grep Version | awk '{print $3}')
            else
                tsql_ver='xxxxx'
            fi

if [ -f /usr/local/bin/tsql ]; then
                TDS_ver=$(tsql -C | grep TDS | awk '{print $3}')
            else
                TDS_ver='xxxxx'
            fi

if [ -f /usr/local/bin/passenger-config ]; then
                passenger_ver=$(passenger-config --version | cut -f3 -d ' ' 2>/dev/null) 
            else
                passenger_ver='xxxxxx'
            fi

if [ -f /usr/bin/node ]; then
                nodejs_ver=$(/usr/bin/node -v 2>/dev/null)
            else
                nodejs_ver='xxxxx'
            fi

openssh_ver=$(dpkg --status openssh-server | grep Version | awk '{print $2}')
openssl_ver=$(dpkg --status openssl | grep Version | awk '{print $2}')

#if [ -f /opt/nginx/sbin/nginx ]; then
#                nginx_ssl=$(/opt/nginx/sbin/nginx -V 2>&1 | grep -oE ".--with-openssl.{0,30}" | cut -f5  -d '/')
#            else
#                nginx_ssl='xxxxx'
#            fi

if [ -f /opt/nginx/sbin/nginx ]; then
     /opt/nginx/sbin/nginx -V 2>&1 | grep ".--with-openssl" 1>/dev/null
       if [ $? -eq 0 ]; then
           nginx_ssl=$(/opt/nginx/sbin/nginx -V 2>&1 | grep -oE ".--with-openssl.{0,30}" | cut -f5  -d '/')
         else
           nginx_ssl='xxxxx'
       fi
   else
       nginx_ssl='xxxxx'
fi

echo $(hostname) "${ubuntu_ver}" "${ruby_ver}" "${python_ver}" "${nginx_ver}" "${tsql_ver}" "${TDS_ver}" "${passenger_ver}" "${nodejs_ver}" "${openssh_ver}" "${openssl_ver}" "${nginx_ssl}" | awk '{ printf "%-30s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-20s %-32s %-20s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}'


