#!/usr/bin/env python3

import re
import uuid

def generate_uuid():
    """Generate a UUID-like string for Xcode project"""
    return str(uuid.uuid4()).upper().replace('-', '')

def add_bundle_to_project():
    """Add GoogleMaps.bundle to the Xcode project"""
    
    # Read the project file
    with open('EcoVision.xcodeproj/project.pbxproj', 'r') as f:
        content = f.read()
    
    # Generate UUIDs for the new entries
    bundle_file_ref_uuid = generate_uuid()
    bundle_build_file_uuid = generate_uuid()
    
    # Add the bundle file reference to PBXFileReference section
    bundle_file_ref = f'\t\t{bundle_file_ref_uuid} /* GoogleMaps.bundle */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.cfbundle; name = GoogleMaps.bundle; path = EcoVision/GoogleMaps.bundle; sourceTree = SOURCE_ROOT; }};'
    
    # Find the PBXFileReference section and add the bundle
    pbx_file_ref_pattern = r'(/\* Begin PBXFileReference section \*/\n)(.*?)(/\* End PBXFileReference section \*/\n)'
    match = re.search(pbx_file_ref_pattern, content, re.DOTALL)
    
    if match:
        file_ref_section = match.group(2)
        # Add the bundle reference before the closing comment
        new_file_ref_section = file_ref_section.rstrip() + '\n\t\t' + bundle_file_ref_uuid + ' /* GoogleMaps.bundle */ = {isa = PBXFileReference; lastKnownFileType = wrapper.cfbundle; name = GoogleMaps.bundle; path = EcoVision/GoogleMaps.bundle; sourceTree = SOURCE_ROOT; };\n\t\t'
        content = content.replace(file_ref_section, new_file_ref_section)
    
    # Add the bundle build file to PBXBuildFile section
    bundle_build_file = f'\t\t{bundle_build_file_uuid} /* GoogleMaps.bundle in Resources */ = {{isa = PBXBuildFile; fileRef = {bundle_file_ref_uuid} /* GoogleMaps.bundle */; }};'
    
    # Find the PBXBuildFile section and add the bundle
    pbx_build_file_pattern = r'(/\* Begin PBXBuildFile section \*/\n)(.*?)(/\* End PBXBuildFile section \*/\n)'
    match = re.search(pbx_build_file_pattern, content, re.DOTALL)
    
    if match:
        build_file_section = match.group(2)
        # Add the bundle build file before the closing comment
        new_build_file_section = build_file_section.rstrip() + '\n\t\t' + bundle_build_file_uuid + ' /* GoogleMaps.bundle in Resources */ = {isa = PBXBuildFile; fileRef = ' + bundle_file_ref_uuid + ' /* GoogleMaps.bundle */; };\n\t\t'
        content = content.replace(build_file_section, new_build_file_section)
    
    # Add the bundle to the Resources build phase
    # Find the main EcoVision target's Resources build phase
    resources_pattern = r'(C448AFA12E447AB1004CDA11 /\* Resources \*/ = \{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = \(\n\t\t\t\t)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\};)'
    match = re.search(resources_pattern, content, re.DOTALL)
    
    if match:
        files_section = match.group(2)
        # Add the bundle to the files list
        new_files_section = files_section.rstrip() + '\n\t\t\t\t' + bundle_build_file_uuid + ' /* GoogleMaps.bundle in Resources */,\n\t\t\t\t'
        content = content.replace(files_section, new_files_section)
    
    # Add the bundle to the main group
    # Find the EcoVision group and add the bundle
    eco_vision_group_pattern = r'(C448AFA52E447AB1004CDA11 /\* EcoVision \*/ = \{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\texceptions = \(\n\t\t\t\);\n\t\t\tpath = EcoVision;\n\t\t\tsourceTree = "<group>";\n\t\t\};)'
    match = re.search(eco_vision_group_pattern, content, re.DOTALL)
    
    if match:
        # We need to add the bundle to the group, but since it's a PBXFileSystemSynchronizedRootGroup,
        # we'll add it as a PBXFileReference in the main group
        main_group_pattern = r'(C448AF9A2E447AB1004CDA11 = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n\t\t\t\t)(.*?)(\n\t\t\t\);\n\t\t\tsourceTree = "<group>";\n\t\t\};)'
        match = re.search(main_group_pattern, content, re.DOTALL)
        
        if match:
            children_section = match.group(2)
            # Add the bundle reference to the children
            new_children_section = children_section.rstrip() + '\n\t\t\t\t' + bundle_file_ref_uuid + ' /* GoogleMaps.bundle */,\n\t\t\t\t'
            content = content.replace(children_section, new_children_section)
    
    # Write the modified content back to the file
    with open('EcoVision.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("Successfully added GoogleMaps.bundle to the Xcode project!")

if __name__ == "__main__":
    add_bundle_to_project()
