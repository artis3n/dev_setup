# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
lookup: github_version
author:
  - Artis3n <artis3n@quantummadness.com>
version_added: "2.8"
requirements:
  - requests
short_description: Get latest release version from a public Github repository
description:
  - This lookup returns the latest release tag of a public Github repository.
options:
  _repos:
    description: Github repositories from which to get versions
    required: True
notes:
  - The version tag is returned however it is defined by the Github repository.
"""

from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display
import requests
from ansible.module_utils._text import to_native

display = Display()


class LookupModule(LookupBase):

    def run(self, repos, variables=None, **kwargs):
        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        versions = []

        for repo in repos:

                # TODO: Sanitize and validate repo
                if not repo:
                    # The Parser error indicates invalid options passed
                    raise AnsibleParserError()

                display.debug("Github version lookup term: %s" % repo)

                # Retrieve the Github API Releases JSON
                try:
                    github_request = requests.get('https://api.github.com/repos/%s/releases/latest' % repo,
                    headers={ 'Accept': 'application/vnd.github.v3+json' }
                    )
                    content = github_request.json()
                    version = content[0].tag_name
                    if version != None and len(version) != 0:
                        versions.append(version)
                    else:
                        raise AnsibleError("Error extracting version from Github API response: %s" % github_request.text)
                except requests.exceptions.RequestException as e:
                    raise AnsibleError("Error communicating with the Github API: %s" % to_native(e))

                display.vvvv(u"Github version lookup using %s as repo" % repo)


        return versions
