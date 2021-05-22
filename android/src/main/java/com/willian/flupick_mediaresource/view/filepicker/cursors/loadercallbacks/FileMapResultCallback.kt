package droidninja.filepicker.cursors.loadercallbacks

import com.willian.flupick_mediaresource.view.filepicker.models.Document
import com.willian.flupick_mediaresource.view.filepicker.models.FileType

/**
 * Created by gabriel on 10/2/17.
 */

interface FileMapResultCallback {
    fun onResultCallback(files: Map<FileType, List<Document>>)
}

