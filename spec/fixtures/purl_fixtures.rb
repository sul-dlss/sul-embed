module PURLFixtures
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
          <access type="discover">
            <machine>
              <world/>
            </machine>
          </access>
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
          <use>
            <human type="useAndReproduction">
              You can use this.
            </human>
            <machine type="creativeCommons">by-nc</machine>
            <human type="creativeCommons">CC Attribution Non-Commercial license</human>
          </use>
        </rightsMetadata>
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
          <access type="discover">
            <machine>
              <world/>
            </machine>
          </access>
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
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
          <objectLabel>Book as Images</objectLabel>
        </identityMetadata>
        <contentMetadata type="image">
          <resource sequence="1" type="image">
            <attr name="label">Resource Label</attr>
            <file size="12345" mimetype="application/png" id="Page1.png" />
            <file size="12346" mimetype="application/png" id="Page2.png" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="discover">
            <machine>
              <world/>
            </machine>
          </access>
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def multi_resource_multi_file_purl
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
        </contentMetadata>
        <contentMetadata type="media">
          <resource sequence="2" type="filez">
            <attr name="label">Resource Label</attr>
            <file size="12345" mimetype="application/pdf" id="Page1.pdf" />
            <file size="12346" mimetype="application/pdf" id="Page2.pdf" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          <access type="discover">
            <machine>
              <world/>
            </machine>
          </access>
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def stanford_restricted_purl
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
  def embargoed_purl
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
              <embargoReleaseDate>#{(Time.now + 1.month).strftime('%Y-%m-%d')}</embargoReleaseDate>
              <group>stanford</group>
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
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
          <use>
            <human type="openDataCommons">ODC-By Attribution License</human>
            <machine type="openDataCommons">odc-by</machine>
          </use>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def geo_purl
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
          <access type="read">
            <machine>
              <world/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
end
