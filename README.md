# snoonet-deploy-cookbook

Cookbook for basic deployment of SnooNet network resources - limited usage as of now, growing with time

## Supported Platforms

Ubuntu 12.04
Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['snoonet']['inspircd']['repo']</tt></td>
    <td>URL</td>
    <td>Source repository for InspIRCd</td>
    <td><tt>https://github.com/inspircd/inspircd.git</tt></td>
  </tr>
  <tr>
    <td><tt>['snoonet']['inspircd']['srcdir']</tt></td>
    <td>String</td>
    <td>Directory to be used for InspIRCd source repo</td>
    <td><tt>/home/snoonet/src/inspircd</tt></td>
  </tr>
  <tr>
    <td><tt>['snoonet']['inspircd']['deploydir']</tt></td>
    <td>String</td>
    <td>Directory to be used for InspIRCd deployment</td>
    <td><tt>/home/snoonet/inspircd</tt></td>
  </tr>
</table>

## Usage

### snoonet-deploy::default

Include `snoonet-deploy` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[snoonet-deploy::default]"
  ]
}
```

## License and Authors

Author:: David Bresnick (david.bresnick@gmail.com)
