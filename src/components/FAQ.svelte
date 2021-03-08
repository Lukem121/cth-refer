<script>
    import { showFAQ } from '../dataStore.js';

    const toggleFAQ = () => {
        showFAQ.update( (v) => !v );
    }
</script>

<!-- This example requires Tailwind CSS v2.0+ -->
<div class="fixed z-10 inset-0 overflow-y-auto">
    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!--
        Background overlay, show/hide based on modal state.
  
        Entering: "ease-out duration-300"
          From: "opacity-0"
          To: "opacity-100"
        Leaving: "ease-in duration-200"
          From: "opacity-100"
          To: "opacity-0"
      -->
      <div class="fixed inset-0 transition-opacity" aria-hidden="true" on:click={toggleFAQ}>
        <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
      </div>
      <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>


      <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full" role="dialog" aria-modal="true" aria-labelledby="modal-headline">
        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
          <div class="sm:flex sm:items-start">
            <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-green-100 sm:mx-0 sm:h-10 sm:w-10">
              <!-- Heroicon name: outline/exclamation -->
              <i class="fas fa-question"></i>
            </div>
            <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
              <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-headline">
                Frequently asked questions!
              </h3>

              <!-- Question 1 -->
                <div class="mt-2">
                    <h2 class="font-bold">This is a cool question!</h2>
                    <p class="text-sm text-gray-500">
                        In order to use this dApp you need to be connected to cheapETH network. Instruction can be found <a href="https://cheapeth.org/metamask.html" target="_blank"><strong><u>here</u></strong></a>. 
                    </p>
                </div>

            </div>
          </div>
        </div>
        <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
          <button type="button" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-green-500 text-base font-medium text-white hover:bg-green-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:ml-3 sm:w-auto sm:text-sm">
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
  