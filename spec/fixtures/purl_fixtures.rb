# frozen_string_literal: true

module PurlFixtures # rubocop:disable Metrics/ModuleLength
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

  def location_embargoed_file_purl_json
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
          "view": "location-based",
          "download": "location-based",
          "location": "spec",
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

  def pdf_public_json
    <<~JSON
    {
      "cocinaVersion": "0.75.0",
      "type": "https://cocina.sul.stanford.edu/models/document",
      "externalIdentifier": "druid:sq929fn8035",
      "label": "Fantasia Apocalyptica musical score (manuscript) : Four trumpets. Chapter 8",
      "version": 5,
      "access": {
        "view": "world",
        "download": "world",
        "controlledDigitalLending": false,
        "copyright": "Copyright (c) The Board of Trustees of the Leland Stanford Junior University. All rights reserved.",
        "useAndReproductionStatement": "The materials are open for research use and may be used freely for non-commercial purposes with an attribution. For commercial permission requests, please contact the Stanford University Archives (universityarchives@stanford.edu)."
      },
      "administrative": {
        "hasAdminPolicy": "druid:vk498gk9921",
        "releaseTags": [
          {
            "who": "dhartwig",
            "what": "collection",
            "date": "2018-09-04T19:11:27.000+00:00",
            "to": "Searchworks",
            "release": true
          }
        ]
      },
      "description": {
        "title": [
          {
            "structuredValue": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Fantasia Apocalyptica musical score (manuscript)",
                "type": "main title",
                "identifier": [],
                "note": [],
                "appliesTo": []
              },
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Four trumpets",
                "type": "subtitle",
                "identifier": [],
                "note": [],
                "appliesTo": []
              },
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Chapter 8",
                "type": "part number",
                "identifier": [],
                "note": [],
                "appliesTo": []
              }
            ],
            "parallelValue": [],
            "groupedValue": [],
            "identifier": [],
            "note": [],
            "appliesTo": []
          }
        ],
        "contributor": [
          {
            "name": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Knuth, Donald Ervin, 1938-",
                "uri": "http://id.loc.gov/authorities/names/n79135509",
                "identifier": [],
                "source": {
                  "code": "naf",
                  "uri": "http://id.loc.gov/authorities/names/",
                  "note": []
                },
                "note": [],
                "appliesTo": []
              }
            ],
            "type": "person",
            "status": "primary",
            "role": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Composer",
                "code": "cmp",
                "uri": "http://id.loc.gov/vocabulary/relators/cmp",
                "identifier": [],
                "source": {
                  "code": "marcrelator",
                  "uri": "http://id.loc.gov/vocabulary/relators/",
                  "note": []
                },
                "note": [],
                "appliesTo": []
              }
            ],
            "identifier": [],
            "note": [],
            "parallelContributor": []
          }
        ],
        "event": [
          {
            "structuredValue": [],
            "type": "production",
            "displayLabel": "Place of creation",
            "date": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "2018-08-08",
                "type": "creation",
                "status": "primary",
                "encoding": {
                  "code": "w3cdtf",
                  "note": []
                },
                "identifier": [],
                "note": [],
                "appliesTo": []
              }
            ],
            "contributor": [],
            "location": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Piteå (Sweden)",
                "code": "sw",
                "uri": "http://id.loc.gov/authorities/names/n80162583",
                "identifier": [],
                "source": {
                  "code": "marccountry",
                  "uri": "http://id.loc.gov/authorities/names/",
                  "note": []
                },
                "note": [],
                "appliesTo": []
              }
            ],
            "identifier": [],
            "note": [],
            "parallelEvent": []
          }
        ],
        "form": [
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "scores",
            "type": "genre",
            "uri": "http://vocab.getty.edu/aat/300026427",
            "identifier": [],
            "source": {
              "code": "aat",
              "uri": "http://vocab.getty.edu/aat",
              "note": []
            },
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "text",
            "type": "resource type",
            "identifier": [],
            "source": {
              "value": "MODS resource types",
              "note": []
            },
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "manuscripts",
            "type": "form",
            "uri": "http://vocab.getty.edu/aat/300028569",
            "identifier": [],
            "source": {
              "code": "aat",
              "uri": "http://vocab.getty.edu/aat",
              "note": []
            },
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "access",
            "type": "reformatting quality",
            "identifier": [],
            "source": {
              "value": "MODS reformatting quality terms",
              "note": []
            },
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "application/pdf",
            "type": "media type",
            "identifier": [],
            "source": {
              "value": "IANA media types",
              "note": []
            },
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "1 text file",
            "type": "extent",
            "identifier": [],
            "note": [],
            "appliesTo": []
          },
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "reformatted digital",
            "type": "digital origin",
            "identifier": [],
            "source": {
              "value": "MODS digital origin terms",
              "note": []
            },
            "note": [],
            "appliesTo": []
          }
        ],
        "geographic": [],
        "language": [
          {
            "appliesTo": [],
            "code": "eng",
            "groupedValue": [],
            "note": [],
            "parallelValue": [],
            "source": {
              "code": "iso639-2b",
              "uri": "http://id.loc.gov/vocabulary/iso639-2",
              "note": []
            },
            "structuredValue": [],
            "uri": "http://id.loc.gov/vocabulary/iso639-2/eng",
            "value": "English"
          }
        ],
        "note": [
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "Fantasia Apocalyptica is a multimedia work for pipe organ, accompanied by several video tracks. It can be regarded as a somewhat literal translation of the Biblical book of Revelation into music.",
            "identifier": [],
            "displayLabel": "Abstract",
            "note": [],
            "appliesTo": []
          }
        ],
        "identifier": [],
        "subject": [
          {
            "structuredValue": [],
            "parallelValue": [],
            "groupedValue": [],
            "value": "Apocalypse in music",
            "type": "topic",
            "uri": "http://id.loc.gov/authorities/subjects/sh2011005782",
            "identifier": [],
            "source": {
              "code": "lcsh",
              "uri": "http://id.loc.gov/authorities/subjects/",
              "note": []
            },
            "note": [],
            "appliesTo": []
          }
        ],
        "access": {
          "url": [],
          "physicalLocation": [
            {
              "structuredValue": [],
              "parallelValue": [],
              "groupedValue": [],
              "value": "SC0097",
              "type": "shelf locator",
              "identifier": [],
              "note": [],
              "appliesTo": []
            }
          ],
          "digitalLocation": [],
          "accessContact": [
            {
              "structuredValue": [],
              "parallelValue": [],
              "groupedValue": [],
              "value": "Stanford University. Libraries. Department of Special Collections and University Archives",
              "type": "repository",
              "uri": "http://id.loc.gov/authorities/names/no2014019980",
              "identifier": [],
              "source": {
                "code": "naf",
                "note": []
              },
              "note": [],
              "valueLanguage": {
                "code": "eng",
                "note": [],
                "source": {
                  "code": "iso639-2b",
                  "note": []
                },
                "valueScript": {
                  "code": "Latn",
                  "note": [],
                  "source": {
                    "code": "iso15924",
                    "note": []
                  }
                }
              },
              "appliesTo": []
            }
          ],
          "digitalRepository": [],
          "note": []
        },
        "relatedResource": [
          {
            "type": "part of",
            "displayLabel": "Finding Aid",
            "title": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Donald E. Knuth Papers (SC0097)",
                "identifier": [],
                "note": [],
                "appliesTo": []
              }
            ],
            "contributor": [],
            "event": [],
            "form": [],
            "language": [],
            "note": [],
            "identifier": [],
            "subject": [],
            "access": {
              "url": [
                {
                  "structuredValue": [],
                  "parallelValue": [],
                  "groupedValue": [],
                  "value": "https://oac.cdlib.org/findaid/ark:/13030/kt2k4035s1/",
                  "identifier": [],
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
            "relatedResource": []
          },
          {
            "type": "in series",
            "displayLabel": "2018-132",
            "title": [
              {
                "structuredValue": [],
                "parallelValue": [],
                "groupedValue": [],
                "value": "Accession",
                "identifier": [],
                "note": [],
                "appliesTo": []
              }
            ],
            "contributor": [],
            "event": [],
            "form": [],
            "language": [],
            "note": [],
            "identifier": [],
            "subject": [],
            "relatedResource": []
          }
        ],
        "marcEncodedData": [],
        "adminMetadata": {
          "contributor": [
            {
              "name": [
                {
                  "structuredValue": [],
                  "parallelValue": [],
                  "groupedValue": [],
                  "code": "CSt",
                  "uri": "http://id.loc.gov/vocabulary/organizations/cst",
                  "identifier": [],
                  "source": {
                    "code": "marcorg",
                    "uri": "http://id.loc.gov/vocabulary/organizations",
                    "note": []
                  },
                  "note": [],
                  "appliesTo": []
                }
              ],
              "type": "organization",
              "role": [
                {
                  "structuredValue": [],
                  "parallelValue": [],
                  "groupedValue": [],
                  "value": "original cataloging agency",
                  "identifier": [],
                  "note": [],
                  "appliesTo": []
                }
              ],
              "identifier": [],
              "note": [],
              "parallelContributor": []
            }
          ],
          "event": [],
          "language": [
            {
              "appliesTo": [],
              "code": "eng",
              "groupedValue": [],
              "note": [],
              "parallelValue": [],
              "source": {
                "code": "iso639-2b",
                "uri": "http://id.loc.gov/vocabulary/iso639-2",
                "note": []
              },
              "status": "primary",
              "structuredValue": [],
              "uri": "http://id.loc.gov/vocabulary/iso639-2/eng",
              "value": "English"
            }
          ],
          "note": [
            {
              "structuredValue": [],
              "parallelValue": [],
              "groupedValue": [],
              "value": "human prepared",
              "type": "record origin",
              "identifier": [],
              "note": [],
              "appliesTo": []
            }
          ],
          "metadataStandard": [],
          "identifier": []
        },
        "purl": "https://purl.stanford.edu/sq929fn8035"
      },
      "identification": {
        "catalogLinks": [],
        "sourceId": "sul:SC0097_2018-123_FA_ms_08"
      },
      "structural": {
        "contains": [
          {
            "type": "https://cocina.sul.stanford.edu/models/resources/document",
            "externalIdentifier": "https://cocina.sul.stanford.edu/fileSet/sq929fn8035-sq929fn8035_1",
            "label": "File 1",
            "version": 4,
            "structural": {
              "contains": [
                {
                  "type": "https://cocina.sul.stanford.edu/models/file",
                  "externalIdentifier": "https://cocina.sul.stanford.edu/file/sq929fn8035-sq929fn8035_1/SC0097_2018-123_FA_ms_08.pdf",
                  "label": "SC0097_2018-123_FA_ms_08.pdf",
                  "filename": "SC0097_2018-123_FA_ms_08.pdf",
                  "size": 12150692,
                  "version": 4,
                  "hasMimeType": "application/pdf",
                  "hasMessageDigests": [
                    {
                      "type": "sha1",
                      "digest": "dd2ff01460fb2e1d8d0aaba542c243317da07e69"
                    },
                    {
                      "type": "md5",
                      "digest": "7e0c891151af86c47b5abe2028cb0d50"
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
                }
              ]
            }
          }
        ],
        "hasMemberOrders": [],
        "isMemberOf": [
          "druid:yz684ny6367"
        ]
      },
      "created": "2023-01-24T00:45:39.000+00:00",
      "modified": "2023-01-24T00:45:39.000+00:00",
      "lock": "druid:sq929fn8035=0"
    }
    JSON
  end
end
