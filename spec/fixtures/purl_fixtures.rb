# frozen_string_literal: true

module PurlFixtures # rubocop:disable Metrics/ModuleLength
  def access_discover_world
    <<-XML
      <access type="discover">
        <machine>
          <world/>
        </machine>
      </access>
    XML
  end

  def access_read_world
    <<-XML
      <access type="read">
        <machine>
          <world/>
        </machine>
      </access>
    XML
  end

  def file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>File Title</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title of the PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf</location>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
          <use>
            <human type="useAndReproduction">
              You can use this.
            </human>
            <machine type="creativeCommons" uri="https://creativecommons.org/publicdomain/mark/1.0/">pdm</machine>
            <human type="creativeCommons">Public Domain Mark 1.0</human>
          </use>
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>File Title</dc:title>
        </oai_dc:dc>
        <mods xmlns="http://www.loc.gov/mods/v3">
          <accessCondition type="license">CC pdm: Public Domain Mark 1.0</accessCondition>
        </mods>
      </publicObject>
    XML
  end

  def file_purl_json
    <<~JSON
      {
        "type": "https://cocina.sul.stanford.edu/models/object",
        "label": "File Title",
        "description": {
          "title": [
            {
              "value": "File Title"
            }
          ]
        },
        "access": {
          "view": "world",
          "download": "world",
          "license": "https://creativecommons.org/publicdomain/mark/1.0/"
        },
        "structural": {
          "contains": [

          ]
        }
      }
    JSON
  end

  def virtual_object_purl_json
    <<~JSON
      {
        "type": "https://cocina.sul.stanford.edu/models/object",
        "label": "File Title",
        "description": {
          "title": [
            {
              "value": "File Title"
            }
          ]
        },
        "access": {
          "view": "world",
          "download": "world",
          "license": "https://creativecommons.org/publicdomain/mark/1.0/"
        },
        "structural": {
          "contains": [],
          "hasMemberOrders": [
            {
              "members": [
                "druid:kq126jw7402"
              ]
            }
          ]
        }
      }
    JSON
  end

  def collection_purl_json
    <<~JSON
      {
        "cocinaVersion": "0.91.2",
        "type": "https://cocina.sul.stanford.edu/models/collection",
        "externalIdentifier": "druid:pp183ft6543",
        "label": "captioned media",
        "version": 2,
        "access": {
          "view": "world"
        },
        "administrative": {
          "hasAdminPolicy": "druid:wr739gs6131"
        },
        "description": {
          "title": [
            {
              "value": "Captioned media",
              "status": "primary"
            }
          ],
          "purl": "https://sul-purl-stage.stanford.edu/pp183ft6543"
        },
        "identification": { },
        "created": "2023-10-20T22:06:02.000+00:00",
        "modified": "2023-10-20T22:25:27.000+00:00",
        "lock": "druid:pp183ft6543="
      }
    JSON
  end

  def stanford_restricted_file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the object</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <attr name="label">PDF1</attr>
            <file size="12345" mimetype="application/pdf" id="Title_of_the_PDF.pdf" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="read">
            <machine>
              <group>stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end

  def stanford_restricted_file_purl_json
    <<~JSON
      {
        "type": "https://cocina.sul.stanford.edu/models/object",
        "label": "File Title",
        "description": {
          "title": [
            {
              "value": "File Title"
            }
          ]
        },
        "access": {
          "view": "stanford",
          "download": "stanford",
          "license": "https://creativecommons.org/publicdomain/mark/1.0/"
        },
        "structural": {
          "contains": [

          ]
        }
      }
    JSON
  end

  def embargoed_file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the object</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>Resource Label</label>
            <file size="12345" mimetype="application/pdf" id="Title of the PDF.pdf" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="read">
            <machine>
              <embargoReleaseDate>2053-12-21</embargoReleaseDate>
              <none/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end

  def embargoed_file_purl_json
    <<~JSON
      {
        "type": "https://cocina.sul.stanford.edu/models/object",
        "label": "File Title",
        "description": {
          "title": [
            {
              "value": "File Title"
            }
          ]
        },
        "access": {
          "view": "stanford",
          "download": "stanford",
          "controlledDigitalLending": false,
          "copyright": "(c) Copyright 2022 by Millie Aila Salvato",
          "embargo": {
              "view": "world",
              "download": "world",
              "controlledDigitalLending": false,
              "releaseDate": "2053-12-21T00:00:00.000+00:00"
          }
        },
        "structural": {
          "contains": [

          ]
        }
      }
    JSON
  end

  def odc_license_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>File Title</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="image">
            <label>File1 Label</label>
            <file size="12345" mimetype="image/jp2" id="tn629pk3948_img_1.jp2" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
          <use>
            <human type="openDataCommons">ODC-By Attribution License</human>
            <machine type="openDataCommons">odc-by</machine>
          </use>
        </rightsMetadata>
      </publicObject>
    XML
  end

  def odc_license_json
    <<~JSON
      {
        "type": "https://cocina.sul.stanford.edu/models/object",
        "label": "File Title",
        "description": {
          "title": [
            {
              "value": "File Title"
            }
          ]
        },
        "access": {
          "license": "https://opendatacommons.org/licenses/by/1-0/"
        },
        "structural": {
          "contains": [

          ]
        }
      }
    JSON
  end

  def geo_purl_public_xml
    <<-XML
      <publicObject id="druid:cz128vq0535" published="2018-07-20T20:56:19Z">
        <identityMetadata>
          <objectLabel>Geo Title</objectLabel>
        </identityMetadata>
        <contentMetadata objectId="cz128vq0535" type="geo">
          <resource id="cz128vq0535_1" sequence="1" type="object">
            <label>Data</label>
            <file id="data.zip" mimetype="application/zip" size="7988069" role="master"></file>
            <file id="data_EPSG_4326.zip" mimetype="application/zip" size="7878575" role="derivative"></file>
          </resource>
          <resource id="cz128vq0535_2" sequence="2" type="preview">
            <label>Preview</label>
            <file id="preview.jpg" mimetype="image/jpeg" size="91351" role="master">
              <imageData width="483" height="477" />
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
        <mods>
          <extension displayLabel="geo">
            <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/fp756wn9369">
              <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
              <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
              <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
                <gml:Envelope gml:srsName="EPSG:4326">
                  <gml:lowerCorner>29.572742 -1.478794</gml:lowerCorner>
                  <gml:upperCorner>35.000308 4.234077</gml:upperCorner>
                </gml:Envelope>
              </gml:boundedBy>
            </rdf:Description>
          </extension>
        </mods>
      </publicObject>
    XML
  end

  def geo_purl_public_json
    <<~JSON
    {
        "type": "https://cocina.sul.stanford.edu/models/geo",
        "label": "2005 Rural Poverty GIS Database: Uganda",
        "externalIdentifier": "druid:cz128vq0535",
        "label": "2005 Rural Poverty GIS Database: Uganda",
        "version": 5,
        "access": {
            "view": "world",
            "download": "world",
            "controlledDigitalLending": false,
            "copyright": "This work is in the Public Domain, meaning that it is not subject to copyright.",
            "useAndReproductionStatement": "This item is in the public domain.  There are no restrictions on use."
        },
        "description": {
            "title": [
                {
                    "value": "2005 Rural Poverty GIS Database: Uganda"
                }
            ],
            "geographic": [
              {
                  "form": [
                      {
                          "value": "application/x-esri-shapefile",
                          "type": "media type",
                          "source": {
                              "value": "IANA media type terms"
                          }
                      },
                      {
                          "value": "Shapefile",
                          "type": "data format"
                      },
                      {
                          "value": "Dataset#Polygon",
                          "type": "type"
                      }
                  ],
                  "subject": [
                      {
                          "structuredValue": [
                              {
                                  "value": "29.572742",
                                  "type": "west"
                              },
                              {
                                  "value": "-1.478794",
                                  "type": "south"
                              },
                              {
                                  "value": "35.000308",
                                  "type": "east"
                              },
                              {
                                  "value": "4.234077",
                                  "type": "north"
                              }
                          ],
                          "type": "bounding box coordinates",
                          "standard": {
                              "code": "EPSG:4326"
                          },
                          "encoding": {
                              "value": "decimal"
                          }
                      }
                  ]
              }
          ]
        },
        "identification": {
            "catalogLinks": [],
            "sourceId": "branner:UG_Ug_Rural_Poverty2005.shp"
        },
        "structural": {
            "contains": [
                {
                    "type": "https://cocina.sul.stanford.edu/models/resources/object",
                    "externalIdentifier": "https://cocina.sul.stanford.edu/fileSet/cz128vq0535-cz128vq0535_1",
                    "label": "Data",
                    "version": 5,
                    "structural": {
                        "contains": [
                            {
                                "type": "https://cocina.sul.stanford.edu/models/file",
                                "externalIdentifier": "https://cocina.sul.stanford.edu/file/cz128vq0535-cz128vq0535_1/data.zip",
                                "label": "data.zip",
                                "filename": "data.zip",
                                "size": 7988069,
                                "version": 5,
                                "hasMimeType": "application/zip",
                                "use": "master",
                                "hasMessageDigests": [
                                    {
                                        "type": "sha1",
                                        "digest": "ee2a8ecb05f7ef52030ac0ecba9885e9d8bcbdcf"
                                    },
                                    {
                                        "type": "md5",
                                        "digest": "fa623f8ace76d47ea30a2477ec4cf09a"
                                    }
                                ],
                                "access": {
                                    "view": "world",
                                    "download": "world",
                                    "controlledDigitalLending": false
                                },
                                "administrative": {
                                    "publish": true,
                                    "sdrPreserve": true,
                                    "shelve": true
                                }
                            },
                            {
                                "type": "https://cocina.sul.stanford.edu/models/file",
                                "externalIdentifier": "https://cocina.sul.stanford.edu/file/cz128vq0535-cz128vq0535_1/data_EPSG_4326.zip",
                                "label": "data_EPSG_4326.zip",
                                "filename": "data_EPSG_4326.zip",
                                "size": 7878575,
                                "version": 5,
                                "hasMimeType": "application/zip",
                                "use": "derivative",
                                "hasMessageDigests": [
                                    {
                                        "type": "sha1",
                                        "digest": "e6df3bdf9109aea41e766bbe0b1408775987f57e"
                                    },
                                    {
                                        "type": "md5",
                                        "digest": "a445ec39c5ab9a18ff3f4f296aba8a55"
                                    }
                                ],
                                "access": {
                                    "view": "world",
                                    "download": "world",
                                    "controlledDigitalLending": false
                                },
                                "administrative": {
                                    "publish": true,
                                    "sdrPreserve": false,
                                    "shelve": true
                                }
                            }
                        ]
                    }
                },
                {
                    "type": "https://cocina.sul.stanford.edu/models/resources/preview",
                    "externalIdentifier": "https://cocina.sul.stanford.edu/fileSet/cz128vq0535-cz128vq0535_2",
                    "label": "Preview",
                    "version": 5,
                    "structural": {
                        "contains": [
                            {
                                "type": "https://cocina.sul.stanford.edu/models/file",
                                "externalIdentifier": "https://cocina.sul.stanford.edu/file/cz128vq0535-cz128vq0535_2/preview.jpg",
                                "label": "preview.jpg",
                                "filename": "preview.jpg",
                                "size": 91351,
                                "version": 5,
                                "hasMimeType": "image/jpeg",
                                "use": "master",
                                "hasMessageDigests": [
                                    {
                                        "type": "sha1",
                                        "digest": "b927d4c603b74e97890dfc84b16653082f99aaaa"
                                    },
                                    {
                                        "type": "md5",
                                        "digest": "69468ab8df5c8712cfd1bfbe0832b516"
                                    }
                                ],
                                "access": {
                                    "view": "world",
                                    "download": "world",
                                    "controlledDigitalLending": false
                                },
                                "administrative": {
                                    "publish": true,
                                    "sdrPreserve": true,
                                    "shelve": true
                                },
                                "presentation": {
                                    "height": 477,
                                    "width": 483
                                }
                            }
                        ]
                    }
                }
            ],
            "hasMemberOrders": [],
            "isMemberOf": [
                "druid:rb371kw9607"
            ]
        },
        "geographic": {}
    }
    JSON
  end

  def was_seed_purl_xml
    <<-XML
      <publicObject id="druid:gb089bd2251" published="2015-07-15T11:49:04-07:00">
        <identityMetadata>
          <sourceId source="sul">ARCHIVEIT-2361-naca.central.cranfield.ac.uk/</sourceId>
          <objectId>druid:gb089bd2251</objectId>
          <objectCreator>DOR</objectCreator>
          <objectLabel>http://naca.central.cranfield.ac.uk/</objectLabel>
          <objectType>item</objectType>
          <otherId name="uuid">9b83e130-2b21-11e5-a344-0050569b52d5</otherId>
          <tag>Remediated By : 4.21.2</tag>
        </identityMetadata>
        <contentMetadata type="webarchive-seed" id="druid:gb089bd2251">
          <resource type="image" sequence="1">
             <file mimetype="image/jp2" id="thumbnail.jp2" size="21862">
                <imageData width="400" height="400" />
             </file>
          </resource>
        </contentMetadata>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#">
        <rdf:Description rdf:about="info:fedora/druid:gb089bd2251">
           <fedora:isMemberOf rdf:resource="info:fedora/druid:mk656nf8485" />
           <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:mk656nf8485" />
        </rdf:Description>
        </rdf:RDF>
        <mods xmlns="http://www.loc.gov/mods/v3">
          <location>
            <url displayLabel="Archived website">https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/</url>
          </location>
        </mods>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:identifier>https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/</dc:identifier>
        </oai_dc:dc>
      </publicObject>
    XML
  end

  def was_seed_purl_json
    <<~JSON
    {
      "cocinaVersion": "0.75.0",
      "type": "https://cocina.sul.stanford.edu/models/webarchive-seed",
      "externalIdentifier": "druid:gb089bd2251",
      "label": "http://naca.central.cranfield.ac.uk/",
      "version": 9,
      "access": {
          "view": "world",
          "download": "world",
          "controlledDigitalLending": false,
          "copyright": "Content is part of a collection of born digital government documents from US Federal executive agencies and Congressional Committees. All materials published by US Federal entities and/employees are in the Public Domain as per section 105 of the Copyright Act (17 USC § 105).",
          "useAndReproductionStatement": "Access is provided in a manner consistent with the Stanford University Libraries Web Archiving Policy (https://library.stanford.edu/projects/web-archiving/policy).",
          "license": "https://creativecommons.org/publicdomain/mark/1.0/"
      },
      "description": {
          "title": [
              {
                  "value": "MAGiC NACA Archive"
              }
          ],
          "access": {
              "url": [
                  {
                      "structuredValue": [],
                      "parallelValue": [],
                      "groupedValue": [],
                      "value": "https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/",
                      "identifier": [],
                      "displayLabel": "Archived website",
                      "note": [],
                      "appliesTo": []
                  }
              ],
              "physicalLocation": [],
              "digitalLocation": [],
              "accessContact": [],
              "digitalRepository": [],
              "note": []
          },
          "purl": "https://purl.stanford.edu/gb089bd2251"
      },
      "identification": {
          "catalogLinks": [],
          "sourceId": "sul:ARCHIVEIT-2361-naca.central.cranfield.ac.uk/"
      },
      "structural": {
          "contains": [
              {
                  "type": "https://cocina.sul.stanford.edu/models/resources/image",
                  "externalIdentifier": "https://cocina.sul.stanford.edu/fileSet/gb089bd2251-87a29daa-141d-45e6-ba8e-82d162a933bc",
                  "label": "",
                  "version": 9,
                  "structural": {
                      "contains": [
                          {
                              "type": "https://cocina.sul.stanford.edu/models/file",
                              "externalIdentifier": "https://cocina.sul.stanford.edu/file/gb089bd2251-87a29daa-141d-45e6-ba8e-82d162a933bc/thumbnail.jp2",
                              "label": "thumbnail.jp2",
                              "filename": "thumbnail.jp2",
                              "size": 30254,
                              "version": 9,
                              "hasMimeType": "image/jp2",
                              "hasMessageDigests": [
                                  {
                                      "type": "sha1",
                                      "digest": "b2cc1a8fae93b96e6ce8dcd86605c731c14bffbd"
                                  },
                                  {
                                      "type": "md5",
                                      "digest": "982cd7655e71297fb875ca1900ce6d6b"
                                  }
                              ],
                              "access": {
                                  "view": "world",
                                  "download": "world",
                                  "controlledDigitalLending": false
                              },
                              "administrative": {
                                  "publish": true,
                                  "sdrPreserve": false,
                                  "shelve": true
                              },
                              "presentation": {
                                  "height": 400,
                                  "width": 400
                              }
                          }
                      ]
                  }
              }
          ],
          "isMemberOf": [
              "druid:mk656nf8485"
          ]
        }
      }
    JSON
  end
end
