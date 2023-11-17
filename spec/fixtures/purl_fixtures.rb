module PurlFixtures
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
  def mods_license_purl
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
          </use>
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>File Title</dc:title>
        </oai_dc:dc>
        <mods xmlns="http://www.loc.gov/mods/v3">
          <accessCondition type="license" xlink:href="https://www.apache.org/licenses/LICENSE-2.0">
            This work is licensed under an Apache License 2.0 license.
          </accessCondition>
        </mods>
      </publicObject>
    XML
  end
  def image_purl_xml
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
  def multi_file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files files files</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title_of_the_PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf</location>
            </file>
          </resource>
          <resource sequence="2" type="file">
            <label>File2 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title_of_2_PDF.pdf">
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
  def hierarchical_file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files files files</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title_of_the_PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf</location>
            </file>
          </resource>
          <resource sequence="2" type="file">
            <label>File2 Label</label>
            <file size="12345" mimetype="application/pdf" id="dir1/dir2/Title_of_2_PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/dir1/dir2/Title_of_2_PDF.pdf</location>
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
  def many_file_purl_xml
    files = (0..3001).map  { |file_num|
      <<-XML
        <resource sequence="1" type="file">
          <label>File #{file_num} Label</label>
          <file size="12345" mimetype="application/pdf" id="file-#{file_num}">
            <location type="url">http://stacks.stanford.edu/file/druid:abc123/file-#{file_num}</location>
          </file>
        </resource>
      XML
    }.join("\n")

    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files files files</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          #{files}
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end
  def large_file_purl_xml
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Files files files</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>File1 Label</label>
            <file size="12345" mimetype="application/pdf" id="Title_of_the_PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf</location>
            </file>
          </resource>
          <resource sequence="2" type="file">
            <label>File2 Label</label>
            <file size="99999999999999999" mimetype="application/pdf" id="Title_of_2_PDF.pdf">
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
  def wonky_filename_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Wonky File</objectLabel>
        </identityMetadata>
        <contentMetadata type="file">
          <resource sequence="1" type="file">
            <label>Wonky File Label</label>
            <file size="12345" mimetype="application/pdf" id="#Title of the PDF.pdf">
              <location type="url">http://stacks.stanford.edu/file/druid:abc123/#Title of the PDF.pdf</location>
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

  def stanford_no_download_restricted_file_purl_xml
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
              <group rule="no-download">stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def stanford_restricted_image_purl_xml
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
  def world_restricted_download_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the object</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="zr649jg5679_1" type="video">
            <label>Tape 1</label>
            <file id="zr649jg5679_em_sl.mp4" mimetype="video/mp4" size="1755489213" />
            <file id="zr649jg5679_thumb.jp2" mimetype="image/jp2" size="253270">
              <imageData width="640" height="480"/>
            </file>
          </resource>
          <resource sequence="2" id="zr649jg5679_2" type="file">
              <label>Transcript</label>
              <file id="zr649jg5679_script.pdf" mimetype="application/pdf" size="248915" />
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          <access type="read">
            <machine>
              <world rule="no-download"/>
            </machine>
          </access>
          <access type="read">
            <file>zr649jg5679_script.pdf</file>
            <machine>
              <world/>
            </machine>
          </access>
        </rightsMetadata>
      </publicObject>
    XML
  end
  def stanford_restricted_download_purl
    <<-XML
    <publicObject>
      <identityMetadata>
        <objectLabel>Title of the object</objectLabel>
      </identityMetadata>
      <contentMetadata type="media">
        <resource sequence="1" id="zr649jg5679_1" type="video">
          <label>Tape 1</label>
          <file id="no-download.mp4" mimetype="video/mp4" size="1755489213" />
          <file id="download-ok.jp2" mimetype="image/jp2" size="253270">
            <imageData width="640" height="480"/>
          </file>
        </resource>
        <resource sequence="2" id="zr649jg5679_2" type="file">
            <label>Transcript</label>
            <file id="download-ok.pdf" mimetype="application/pdf" size="248915" />
        </resource>
      </contentMetadata>
      <rightsMetadata>
        #{access_discover_world}
        <access type="read">
          <machine>
            <group rule="no-download">stanford</group>
          </machine>
        </access>
        <access type="read">
          <file>download-ok.jp2</file>
          <file>download-ok.pdf</file>
          <machine>
            <group >stanford</group>
          </machine>
        </access>
      </rightsMetadata>
    </publicObject>
  </access>
    XML
  end
  def stanford_restricted_multi_file_purl_xml
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
  def embargoed_stanford_file_purl_xml
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
      <publicObject id="druid:cz128vq0535" published="2018-07-20T20:56:19Z">
        <identityMetadata>
          <objectLabel>Geo Title</objectLabel>
        </identityMetadata>
        <contentMetadata objectId="cz128vq0535" type="geo">
          <resource id="cz128vq0535_1" sequence="1" type="object">
            <label>Data</label>
            <file id="data.zip" mimetype="application/zip" size="7988069" role="master">
              <geoData>
                <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/cz128vq0535">
                  <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
                  <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
                  <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
                    <gml:Envelope gml:srsName="EPSG:4326">
                      <gml:lowerCorner>29.572742 -1.478794</gml:lowerCorner>
                      <gml:upperCorner>35.000308 4.234077</gml:upperCorner>
                    </gml:Envelope>
                  </gml:boundedBy>
                  <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="http://sws.geonames.org/226074/about.rdf" dc:language="eng" dc:title="Uganda" />
                </rdf:Description>
              </geoData>
            </file>
            <file id="data_EPSG_4326.zip" mimetype="application/zip" size="7878575" role="derivative">
              <geoData srsName="EPSG:4326" />
            </file>
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
                  <gml:lowerCorner>-123.387626 38.298673</gml:lowerCorner>
                  <gml:upperCorner>-122.528843 39.399103</gml:upperCorner>
                </gml:Envelope>
              </gml:boundedBy>
            </rdf:Description>
          </extension>
        </mods>
      </publicObject>
    XML
  end
  def geo_purl_index_map
    <<-XML
      <publicObject id="druid:ts545zc6250" published="2018-09-10T12:43:23Z" publishVersion="dor-services/5.31.1">
        <identityMetadata>
          <sourceId source="branner">topo_index_JMM_B14_J59.shp</sourceId>
          <objectId>druid:ts545zc6250</objectId>
        </identityMetadata>
        <contentMetadata objectId="ts545zc6250" type="geo">
          <resource id="ts545zc6250_1" sequence="1" type="object">
            <label>Data</label>
            <file id="data.zip" mimetype="application/zip" size="103504" role="master">
              <geoData>
                <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/ts545zc6250">
                  <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
                  <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
                  <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
                    <gml:Envelope gml:srsName="EPSG:4326">
                      <gml:lowerCorner>124.0 38.0</gml:lowerCorner>
                      <gml:upperCorner>130.0 42.666667</gml:upperCorner>
                    </gml:Envelope>
                  </gml:boundedBy>
                  <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="" dc:language="eng" dc:title="Korea (North)" />
                </rdf:Description>
              </geoData>
            </file>
            <file id="data_EPSG_4326.zip" mimetype="application/zip" size="25807" role="derivative">
              <geoData srsName="EPSG:4326" />
            </file>
            <file id="index_map.json" mimetype="application/json" size="411978" role="master" />
          </resource>
          <resource id="ts545zc6250_2" sequence="2" type="preview">
            <label>Preview</label>
            <file id="preview.jpg" mimetype="image/jpeg" size="80392" role="master">
              <imageData width="769" height="984" />
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

  def video_purl_with_vtt
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the single video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="video">
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000"></file>
            <file id="abc_123_cap.webvtt" mimetype="text/vtt" size="176218"></file>
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
          <dc:title>title of video with vtt</dc:title>
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
            <label>First Video</label>
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
          </resource>
          <resource sequence="2" id="abc321_2" type="video">
            <label>Second Video</label>
            <file id="abc_321.mp4" mimetype="video/mp4" size="666000000">
              <videoData duration="-P1W" height="288" width="352"/>
            </file>
          </resource>
          <resource sequence="3" id="bb051hp9404_2" type="file">
            <label>Transcript</label>
            <file id="abc_123_script.pdf" mimetype="application/pdf" size="557708"></file>
          </resource>
          <resource sequence="4" id="abc333" type="video">
            <file id="abc_333.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="P0DT1H2M3S" height="288" width="352"/>
            </file>
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

  def video_purl_unrestricted
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
          <access type="read">
            <machine>
              <world/>
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
            <label>First Video</label>
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000">
              <videoData duration="PDDTMMS"/>
            </file>
          </resource>
          <resource sequence="2" id="abc321_1" type="video">
            <label>Second Video</label>
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
            <file id="abc_123.mp4" mimetype="video/mp4" size="152000000"></file>
          </resource>
          <resource sequence="2" id="bb051hp9404_2" type="image">
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

  def audio_purl_with_thumbnail
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="audio">
            <file id="abc_123.mp3" mimetype="audio/mpeg" size="770433"></file>
            <file id="abc_123_thumb.jp2" mimetype="image/jp2" size="329964" publish="yes" shelve="yes" preserve="yes">
              <imageData height="678" width="678"/>
            </file>
          </resource>
        </contentMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>DC title of audio</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def audio_purl_multiple
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>Title of the video</objectLabel>
        </identityMetadata>
        <contentMetadata type="media">
          <resource sequence="1" id="abc123_1" type="audio">
            <label>First Audio</label>
            <file id="abc_123.mp3" mimetype="audio/mpeg" size="770433">
              <audioData duration="PT43S"/>
            </file>
          </resource>
          <resource sequence="1" id="abc456_1" type="audio">
            <label>Second Audio</label>
            <file id="abc_456.mp3" mimetype="audio/mpeg" size="770433"></file>
          </resource>
        </contentMetadata>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>DC title of audio</dc:title>
        </oai_dc>
      </publicObject>
    XML
  end

  def file_thumb_purl
    <<-XML
      <publicObject>
        <contentMetadata type="file">
          <resource id="audio_1" type="audio">
            <file id="audio.mp3" mimetype="audio/mpeg" size="77033"></file>
            <file id="audio_1.jp2" mimetype="image/jp2" size="42"></file>
          </resource>
          <resource id="video_1" type="video">
            <file id="video.mp4" mimetype="video/mp4" size="77023"></file>
            <file id="video_1.jp2" mimetype="image/jp2" size="42"></file>
          </resource>
          <resource id="video_2" type="video">
            <file id="video2.mp4" mimetype="video/mp4" size="77023"></file>
            <file id="video2.jpg" mimetype="image/jpg" size="1234"></file>
          </resource>
          <resource id="book_1" type="image">
            <file id="book1.jp2" mimetype="image/jp2" size="77041"></file>
          </resource>
        </contentMetadata>
      </publicObject>
    XML
  end

  def file_and_object_level_downloadable_thumb_purl
    <<-XML
      <publicObject>
        <contentMetadata type="file">
          <resource id="audio_1" type="audio">
            <file id="audio.mp3" mimetype="audio/mpeg" size="77033"></file>
            <file id="audio_1.jp2" mimetype="image/jp2" size="42"></file>
          </resource>
          <resource id="video_1" type="video">
            <file id="video.mp4" mimetype="video/mp4" size="77023"></file>
            <file id="video_1.jp2" mimetype="image/jp2" size="42"></file>
          </resource>
          <resource id="video_2" type="video">
            <file id="video2.mp4" mimetype="video/mp4" size="77023"></file>
            <file id="video2.jpg" mimetype="image/jpg" size="1234"></file>
          </resource>
          <resource id="book_1" type="image">
            <file id="book1.jp2" mimetype="image/jp2" size="77041"></file>
          </resource>
          <resource id="thumb_1" type="thumb" thumb="yes">
            <file id="thumb.jp2" mimetype="image/jp2" size="7722"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_read_world}
        </rightsMetadata>
      </publicObject>
    XML
  end

  def pdf_document_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>PDF Title</objectLabel>
        </identityMetadata>
        <contentMetadata type="document">
          <resource sequence="1" type="document">
            <label>PDF Label</label>
            <file id="TheNameOfThe.pdf" mimetype="application/pdf" size="12345"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>PDF Title</dc:title>
        </oai_dc:dc>
      </publicObject>
    XML
  end

  def threeD_object_purl
    <<-XML
      <publicObject>
        <identityMetadata>
          <objectLabel>3D Object Title</objectLabel>
        </identityMetadata>
        <contentMetadata type="3d">
        <resource sequence="1" type="file">
          <file id="some-derivative.ply" mimetype="" size="1234"></file>
        </resource>
          <resource sequence="2" type="3d">
            <file id="theobj-file.obj" mimetype="text/plain" size="54321"></file>
          </resource>
        </contentMetadata>
        <rightsMetadata>
          #{access_discover_world}
          #{access_read_world}
        </rightsMetadata>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>3D Object Title</dc:title>
        </oai_dc:dc>
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
