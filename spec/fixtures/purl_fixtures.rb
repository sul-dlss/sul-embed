module PURLFixtures
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

  def file_purl
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
            <machine type="creativeCommons">by-nc</machine>
            <human type="creativeCommons">CC Attribution Non-Commercial license</human>
          </use>
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>File Title</dc:title>
        </oai_dc:dc>
      </publicObject>
    XML
  end
  def image_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the image</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource sequence="1" type="image">
            <label>Image1</label>
            <file size="12345" mimetype="image/jp2" id="image_001.jp2">
              <imageData height="6123" width="5321" />
            </file>
          </resource>
          <resource sequence="2" type="image">
            <label>Image2</label>
            <file size="23456" mimetype="image/jp2" id="image_002.jp2">
              <imageData height="7246" width="6123" />
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
          <copyright>
            <human type="copyright">
              Copyright © 1976 The Board of Trustees of the Leland Stanford Junior University. All rights reserved.
            </human>
          </copyright>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_file_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files files files</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title of the PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf</location>
            </file>
          </resource>
          <resource sequence="2" type="file">
            <label>File2 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title of 2 PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_2_PDF.pdf</location>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def image_no_size_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>image without size</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource sequence="1" type="image">
            <attr name="label">Resource Label</attr>
            <file mimetype="application/png" id="Page1.png" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def image_empty_size_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>image empty size</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource sequence="1" type="image">
            <attr name="label">Resource Label</attr>
            <file size="" mimetype="application/png" id="Page1.png" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_resource_multi_type_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files and what not</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <attr name="label">Resource Label</attr>
            <file size="12345" mimetype="application/pdf" id="Page1.pdf" />
            <file size="12346" mimetype="application/pdf" id="Page2.pdf" />
          </resource>
          <resource id="media1" sequence="2" type="bar">
            <label>mp4-normal</label>
            <file id="JessieSaysNo.mp4" mimetype="video/mp4" size="190916">
              <videoData height="288" width="352"/>
            </file>
          </resource>
          <resource id="image2" sequence="3" type="foo">
            <file id="bw662rg0319_00_0002.jp2" mimetype="image/jp2" size="2799535">
              <imageData height="4442" width="3417"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_image_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Book as Images</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource id="image1" sequence="1" type="image">
            <file id="bw662rg0319_00_0001.jp2" mimetype="image/jp2" size="3458791">
              <imageData height="4442" width="3417"/>
            </file>
          </resource>
          <resource id="image2" sequence="2" type="image">
            <file id="bw662rg0319_00_0002.jp2" mimetype="image/jp2" size="2799535">
              <imageData height="4442" width="3417"/>
            </file>
          </resource>
          <resource id="image3" sequence="3" type="image">
            <file id="bw662rg0319_00_0003.jp2" mimetype="image/jp2" size="2253773">
              <imageData height="4442" width="3417"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_media_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Multiple Videos in same contentMetadata</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource id="media1" sequence="1" type="video">
            <label>mp4-normal</label>
            <file id="JessieSaysNo.mp4" mimetype="video/mp4" size="190916">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
          <resource id="media2" sequence="2" type="video">
            <label>mp4-slow</label>
            <file id="JessieSaysNo-Slow.mp4" mimetype="video/mp4" size="738559">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_resource_multi_media_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files and what not</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" type="file">
            <attr name="label">Resource Label</attr>
            <file size="12345" mimetype="application/pdf" id="Page1.pdf" />
            <file size="12346" mimetype="application/pdf" id="Page2.pdf" />
          </resource>
          <resource sequence="1" id="abc123_1" type="video">
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000"></file>
          </resource>
          <resource sequence="2" id="bb051hp9404_2" type="file">
            <label>Image of media (1 of 1)</label>
            <file id="bd786fy6312_img.jp2" mimetype="image/jp2" size="213147">
              <imageData height="384" width="2896"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def stanford_restricted_file_purl
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
  def stanford_restricted_image_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the object</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource sequence="1" type="image">
            <label>Image1</label>
            <file size="12345" mimetype="image/jp2" id="image_001.jp2">
              <imageData height="8423" width="6321" />
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="read">
            <machine>
              <group>stanford</group>
              <world rule="no-download"/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def stanford_restricted_multi_file_purl
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
          <resource sequence="2" type="file">
            <attr name="label">PDF2</attr>
            <file size="12346" mimetype="application/pdf" id="Title_of_the_other_PDF.pdf" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="read">
            <file>Title_of_the_PDF.pdf</file>
            <machine>
              <group>stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def embargoed_stanford_file_purl
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
              <embargoReleaseDate>#{(Time.current + 1.month).strftime('%Y-%m-%d')}</embargoReleaseDate>
              <group>stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def embargoed_file_purl
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
              <embargoReleaseDate>#{(Time.current + 1.month).strftime('%Y-%m-%d')}</embargoReleaseDate>
              <none/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def hybrid_object_purl
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
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title of the PDF.pdf" />
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
  def geo_purl_public
     <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Geo Title</objectLabel>
        </identityMetadata>
        <contentMetadata type="geo">
          <resource sequence="1" type="object">
            <label>Data</label>
            <file id="data.zip" mimetype="application/zip" size="127368" role="master">
              <geoData>
                <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/fp756wn9369">
                  <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
                  <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
                  <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
                    <gml:Envelope gml:srsName="EPSG:4326">
                      <gml:lowerCorner>-123.387626 38.298673</gml:lowerCorner>
                      <gml:upperCorner>-122.528843 39.399103</gml:upperCorner>
                    </gml:Envelope>
                  </gml:boundedBy>
                  <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="" dc:language="eng" dc:title="Russian River Watershed (Calif.)"/>
                  <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="http://sws.geonames.org/5397100/about.rdf" dc:language="eng" dc:title="Sonoma County (Calif.)"/>
                  <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="http://sws.geonames.org/5372163/about.rdf" dc:language="eng" dc:title="Mendocino County (Calif.)"/>
                </rdf:Description>
              </geoData>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def geo_purl_restricted
    <<-XML
      <publicObject id="druid:fp756wn9369" published="2015-02-04T20:03:27-08:00">
        <identityMetadata>
          <sourceId source="branner">rr_1100kgrdu.shp</sourceId>
          <objectId>druid:fp756wn9369</objectId>
        </identityMetadata>
        <contentMetadata objectId="fp756wn9369" type="geo">
          <resource id="fp756wn9369_1" sequence="1" type="object">
            <label>Data</label>
            <file id="data.zip" mimetype="application/zip" size="127368" role="master">
              <geoData>
                <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/fp756wn9369">
                  <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
                  <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
                  <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
                    <gml:Envelope gml:srsName="EPSG:4326">
                      <gml:lowerCorner>-123.387626 38.298673</gml:lowerCorner>
                      <gml:upperCorner>-122.528843 39.399103</gml:upperCorner>
                    </gml:Envelope>
                  </gml:boundedBy>
                </rdf:Description>
              </geoData>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          <access type="read">
            <machine>
              <group>Stanford</group>
            </machine>
          </access>
          <use>
            <human type="useAndReproduction">
              These data are licensed by Stanford Libraries and are available to Stanford University affiliates only. Affiliates are limited to current faculty, staff and students. These data may not be reproduced or used for any purpose without permission. For more information please contact brannerlibrary@stanford.edu.
            </human>
            <human type="creativeCommons"/>
            <machine type="creativeCommons"/>
          </use>
          <copyright>
            <human>Copyright ownership resides with the originator.</human>
          </copyright>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def was_seed_purl
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
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:identifier>https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/</dc:identifier>
        </oai_dc:dc>
      </publicObject>
    XML
  end
  def image_with_pdf_purl
    <<-XML
      <publicObject id="druid:bb112fp0199" published="2014-04-10T16:06:21-07:00">
        <identityMetadata>
          <sourceId source="sul">M1711_Series3_Box104_Folder19</sourceId>
          <objectId>druid:bb112fp0199</objectId>
          <objectCreator>DOR</objectCreator>
          <objectLabel>Writings - "How to Test a Good Trumpet," The Instrumentalist 31(8):57-58 (reprint, 2 pp.)</objectLabel>
          <objectType>item</objectType>
          <adminPolicy>druid:wg541jt7173</adminPolicy>
          <otherId name="uuid">b655a82e-fc3d-11e1-b443-0016034322e2</otherId>
          <tag>Project : Musical Acoustics Research Library</tag>
          <tag>Process : Content Type : Book (flipbook, ltr)</tag>
          <tag>Project : Musical Acoustics Research Library</tag>
        </identityMetadata>
        <contentMetadata type="book" objectId="bb112fp0199">
          <resource type="page" sequence="1" id="bb112fp0199_1">
            <label>Page 1</label>
            <file id="bb112fp0199_06_0001.pdf" mimetype="application/pdf" size="2365677">
          </file>
            <file id="bb112fp0199_00_0001.jp2" mimetype="image/jp2" size="3117394">
              <imageData width="3629" height="4556"/>
            </file>
          </resource>
          <resource type="page" sequence="2" id="bb112fp0199_2">
            <label>Page 2</label>
            <file id="bb112fp0199_06_0002.pdf" mimetype="application/pdf" size="2398016">
          </file>
            <file id="bb112fp0199_00_0002.jp2" mimetype="image/jp2" size="3117384">
              <imageData width="3629" height="4556"/>
            </file>
          </resource>
          <resource type="object" sequence="3" id="bb112fp0199_3">
            <label>Object 1</label>
            <file id="bb112fp0199_31_0000.pdf" mimetype="application/pdf" size="4761613">
          </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
          <use>
            <human type="useAndReproduction">Property rights reside with the repository. Literary rights reside with the creators of the documents or their heirs. To obtain permission to publish or reproduce, please contact the Special Collections Public Services Librarian at speccollref@stanford.edu.</human>
            <human type="creativeCommons"/>
            <machine type="creativeCommons"/>
          </use>
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>Writings - "How to Test a Good Trumpet," The Instrumentalist 31(8):57-58 (reprint, 2 pp.)</dc:title>
          <dc:relation type="collection">Musical Acoustics Research Library collection, 1956-2007</dc:relation>
        </oai_dc:dc>
      </publicObject>
    XML
  end
  def image_with_pdf_restricted_purl
    <<-XML
      <publicObject id="druid:bb112fp0199" published="2014-04-10T16:06:21-07:00">
        <identityMetadata>
          <sourceId source="sul">M1711_Series3_Box104_Folder19</sourceId>
          <objectId>druid:bb112fp0199</objectId>
          <objectCreator>DOR</objectCreator>
          <objectLabel>Writings - "How to Test a Good Trumpet," The Instrumentalist 31(8):57-58 (reprint, 2 pp.)</objectLabel>
          <objectType>item</objectType>
          <adminPolicy>druid:wg541jt7173</adminPolicy>
          <otherId name="uuid">b655a82e-fc3d-11e1-b443-0016034322e2</otherId>
          <tag>Project : Musical Acoustics Research Library</tag>
          <tag>Process : Content Type : Book (flipbook, ltr)</tag>
          <tag>Project : Musical Acoustics Research Library</tag>
        </identityMetadata>
        <contentMetadata type="book" objectId="bb112fp0199">
          <resource type="page" sequence="1" id="bb112fp0199_1">
            <label>Page 1</label>
            <file id="bb112fp0199_06_0001.pdf" mimetype="application/pdf" size="2365677">
          </file>
            <file id="bb112fp0199_00_0001.jp2" mimetype="image/jp2" size="3117394">
              <imageData width="3629" height="4556"/>
            </file>
          </resource>
          <resource type="page" sequence="2" id="bb112fp0199_2">
            <label>Page 2</label>
            <file id="bb112fp0199_06_0002.pdf" mimetype="application/pdf" size="2398016">
          </file>
            <file id="bb112fp0199_00_0002.jp2" mimetype="image/jp2" size="3117384">
              <imageData width="3629" height="4556"/>
            </file>
          </resource>
          <resource type="object" sequence="3" id="bb112fp0199_3">
            <label>Object 1</label>
            <file id="bb112fp0199_31_0000.pdf" mimetype="application/pdf">
          </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          <access type="read">
            <machine>
              <group>Stanford</group>
            </machine>
          </access>
          <use>
            <human type="useAndReproduction">Property rights reside with the repository. Literary rights reside with the creators of the documents or their heirs. To obtain permission to publish or reproduce, please contact the Special Collections Public Services Librarian at speccollref@stanford.edu.</human>
            <human type="creativeCommons"/>
            <machine type="creativeCommons"/>
          </use>
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>Yolo</dc:title>
          <dc:relation type="collection">Musical Acoustics Research Library collection, 1956-2007</dc:relation>
        </oai_dc:dc>
      </publicObject>
    XML
  end

  def single_video_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the single video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="read">
            <machine>
              <location>spec</location>
            </machine>
          </access>
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def video_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
          <resource sequence="2" id="abc321_1" type="video">
            <label>Second Video</label>
            <file id="abc_321.mp4" mimetype="video/mp4" size="666000000">
              <videoData duration="-P1W" height="288" width="352"/>
            </file>
          </resource>
          <resource sequence="3" id="bb051hp9404_2" type="file">
            <label>Transcript</label>
            <file id="abc_123_script.pdf" mimetype="application/pdf" size="557708"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
          <access type="read">
            <file>abc_123.mp4</file>
            <machine>
              <location>spec</location>
            </machine>
          </access>
          <access type="read">
            <file>abc_321.mp4</file>
            <machine>
              <group>Stanford</group>
            </machine>
          </access>
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def video_with_spaces_in_filename_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of a video with spaces in the file name</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <file id="A video title.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def invalid_video_duration_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="PDDTMMS"/>
            </file>
          </resource>
          <resource sequence="2" id="abc321_1" type="video">
            <file id="abc_321.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="PDDTMMS"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def long_label_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <label>The First Video Has An Overly Long Title, With More Words Than Can Practically Be Displayed</label>
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
          <resource sequence="2" id="abc321_1" type="video">
            <label>2nd Video Has A Long Title, But Not Too Long</label>
            <file id="abc_321.mp4" mimetype="video/mp4" size="666000000"></file>
          </resource>
          <resource sequence="3" id="bb051hp9404_2" type="file">
            <label>Transcript</label>
            <file id="abc_123_script.pdf" mimetype="application/pdf" size="557708"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
          <access type="read">
            <file>abc_123.mp4</file>
            <machine>
              <location>spec</location>
            </machine>
          </access>
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def video_purl_with_image
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video (with an image)</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <!-- note that the resource-level thumb is listed before the media file for the resource;
              the order of the two (if there is a resource-level thumb) shouldn't matter -->
            <file id="abc_123_thumb.jp2" mimetype="image/jp2" size="274083">
              <imageData height="1491" width="1719"/>
            </file>
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000"></file>
          </resource>
          <resource sequence="2" id="bb051hp9404_2" type="file">
            <label>Image of media (1 of 1)</label>
            <file id="bd786fy6312_img.jp2" mimetype="image/jp2" size="213147">
              <imageData height="384" width="2896"/>
            </file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>stupid dc title of video</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def audio_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="audio">
            <file id="abc_123.mp3" mimetype="audio/mpeg" size="770433"></file>
          </resource>
        </contentMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>DC title of audio</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def empty_content_metadata_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the blank content object</objectLabel>
        </identityMetadata>
        <contentMetadata type="file"></contentMetadata>
      </publicObject>
    XML
  end
end
