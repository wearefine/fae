import httplib, json
import getopt, sys, os
import subprocess

def get_connection(organization):
  return httplib.HTTPSConnection('%s.slack.com' % organization)

def get_url(token):
  return '/services/hooks/incoming-webhook?token=%s' % token

def get_data_from_git(format_string, commit):
  return subprocess.check_output(['git', 'log', '-1', '--format=format:%s' % format_string, commit])

def get_author(commit):
  return get_data_from_git('%an <%ae>', commit)

def get_date(commit):
  return get_data_from_git('%aD', commit)

def get_title(commit):
  return get_data_from_git('%s', commit)

def get_full_message(commit):
  return get_data_from_git('%b', commit)

def post_message(connection, url, success, project):
  headers = {'Content-Type': 'application/json'}
  build_url = os.environ['BUILD_URL']
  build_number = os.environ['BUILD_NUMBER']
  branch = os.environ['BRANCH']
  commit = os.environ['COMMIT']

  status_text = 'succeeded' if success else 'failed'
  color = 'good' if success else 'danger'
  text = '<%s|Build #%s> for project %s on branch %s' % (build_url, build_number, project, branch)

  message = {
    'username': 'Shippable',
    'fallback': text,
    # 'pretext': text,
    'color': color,
    'icon_emoji': ':shipit:',
    'fields': [
      {
        'title': '%s - %s branch' % (project, branch),
        'value': '<%s|Build #%s> %s' % (build_url, build_number, status_text)
      },
      {
        'title': get_author(commit),
        'value': get_title(commit)
      }
    ]
  }

  connection.request('POST', url, json.dumps(message), headers)
  response = connection.getresponse()
  print response.read().decode()

def main():
  try:
    opts, args = getopt.getopt(sys.argv[1:], ':sf', ['project=', 'org=', 'token='])
  except getopt.GetoptError as err:
    print str(err)
    sys.exit(2)

  success = False
  project = None
  organization = None
  token = None
  for o, arg in opts:
    if o == '-s':
      success = True
    elif o == '--project':
      project = arg
    elif o == '--org':
      organization = arg
    elif o == '--token':
      token = arg

  connection = get_connection(organization)
  url = get_url(token)
  post_message(connection, url, success, project)

if __name__ == '__main__':
  main()